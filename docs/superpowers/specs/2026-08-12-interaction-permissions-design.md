# Interaction Permissions Design

## Problem

`atomic_admin`-hosted backends declare "interactions" (launch tiles, forms, dashboards, etc.) that skipper displays and lets users act on. Today every interaction returned by a backend is shown to every user who can access that backend at all — there's no way to scope an individual interaction (e.g. `activity_manager`) to a specific permission (e.g. `remote:launch:activity_manager`).

## Goals

- Let a backend declare per-interaction permission requirements.
- Let skipper hide/block interactions a user doesn't have permission for, using skipper's existing permission model.
- No breaking change for existing interactions that declare no permissions.

## Non-goals

- Auto-discovery/sync of permission strings into skipper's `Permission` table (deferred — permissions are created manually, same as today's fixed set).
- Any change to the JWT skipper sends to backends (`aud` only, no user identity/scopes).

## Architecture

Enforcement is split across two repos with a clean responsibility boundary:

- **atomic_admin** (the gem embedded in backends) is purely declarative. It has no concept of the calling user, so it cannot enforce anything — it just tags each interaction with the permission string(s) required to see it and exposes that tag in the resolved JSON.
- **skipper** (the admin UI) does all enforcement. It already knows, for the current request, which user is asking and what permissions they hold for the specific backend in question (via `Role → Permission`, `system_role`, and per-backend `BackendAccess`). It filters/blocks based on the `permissions` field each interaction now carries.

## atomic_admin changes

`lib/atomic_admin/interaction/base.rb` already has the needed change on the current branch (uncommitted):

```ruby
module AtomicAdmin::Interaction
  class Base
    attr_accessor :key, :type, :key, :title, :icon, :order, :data, :permissions

    def initialize(key:, type:, title: nil, icon: nil, order: 0, permissions: [], **kwargs)
      @key = key
      @type = type
      @title = title
      @icon = icon
      @order = order
      @permissions = permissions
      @data = kwargs
    end

    def resolve(**kwargs)
      {
        key: key,
        type: type,
        title: title,
        icon: icon,
        permissions: permissions,
      }
    end
  end
end
```

No further code changes needed here:

- `permissions` defaults to `[]`, so existing interactions that don't declare it behave exactly as before.
- Subclasses (`Launch`, `Resource`, `JsonForm`, `Analytics`, `Readonly`) call `super(**kwargs)` inside their own `resolve`, so `permissions` flows through into every interaction type's final JSON automatically (verified against `lib/atomic_admin/interaction/launch.rb`).
- `Manager#resolve` (`lib/atomic_admin/interaction/manager.rb`) continues to just sort and resolve every registered interaction — it does not filter. Filtering happens entirely on the skipper side.

Documentation: add a short note to `docs/interactions.md` explaining the `permissions:` option (available on all interaction types, since it lives on `Base`) and calling out that a new permission string requires a corresponding `Permission` row to be created in skipper, or the interaction will be invisible to everyone.

## skipper changes

### 1. `Ability` — expose the existing remote-permission check

`app/models/ability.rb` already has exactly the check needed, as a private method:

```ruby
def user_has_remote_permission?(user, backend, permission)
  # Prefer the user's system role over the backend roles
  return true if user_has_internal_permission?(user, permission)

  accesss = user.backend_accesses.eager_load(role: :permissions).find_by(backend: backend)
  return false if accesss.nil?
  accesss.role.permissions.where(value: permission).any?
end
```

It already accepts an array and matches ANY of the given permission strings (via `Array#include?` / an implicit `IN` query), and already checks the user's global `system_role` before falling back to their per-backend `BackendAccess` role. This is exactly the semantics needed for interaction permissions (ANY-of-list match). The only change is moving this method above the `private` line so it's callable from controllers.

### 2. Filter the two `interactions` proxy actions

`Api::V1::ApplicationInstancesController#interactions` and `Api::V1::ApplicationsController#interactions` currently have identical, unfiltered bodies:

```ruby
guard :interactions, "remote:read:applications"
def interactions
  res = backend.api.get("#{url}/#{params[:id]}/interactions")
  render json: parse(res.body), status: res.code
end
```

Since both need the same filtering added, collapse the duplication into `Api::V1::BackendResourceController` (the shared base class) as a single `interactions` action:

```ruby
def interactions
  res = backend.api.get("#{url}/#{params[:id]}/interactions")
  data = parse(res.body)
  data["interactions"]&.select! { |i| interaction_visible?(i) }
  render json: data, status: res.code
end

protected

def interaction_visible?(interaction)
  permissions = interaction["permissions"]
  permissions.blank? || current_ability.user_has_remote_permission?(current_user, backend, permissions)
end
```

Both subclasses drop their now-duplicate `interactions` method body and keep only their `guard :interactions, "remote:read:applications"` declaration. That coarse, action-level guard is unchanged and still applies first — per-interaction filtering is additive on top of it, not a replacement.

`current_ability` is CanCan's standard controller helper (already used in `api_controller.rb`'s `backend` method), so no new dependency is introduced.

### 3. Close the direct-launch gap: `ExternalLaunchController`

`ExternalLaunchController#launch` does **not** go through either controller above — it independently fetches a backend's interactions list and finds one interaction by `key` to perform the actual launch:

```ruby
def launch
  backend = Backend.find_by!(slug: params[:backend_slug])

  if !current_user.can?(:read, backend)
    return render status: :forbidden, file: "public/403.html", layout: false
  end

  path = if params[:application_instance_id]
    "/applications/#{params[:application_id]}/application_instances/#{params[:application_instance_id]}/interactions"
  else
    "/applications/#{params[:application_id]}/interactions"
  end
  resp = backend.api.get(path)
  interactions = JSON.parse(resp.body)["interactions"]
  interaction = interactions.find { |i| i["type"] == "launch" && i["key"] == params[:launch_id] }

  if interaction.nil?
    return render status: :not_found, file: "public/404.html", layout: false
  end

  @launch_url = interaction["launch_url"]
  @jwt = helpers.issue_auth_token(...)
  render template: "external_launch/launch", layout: false
end
```

This is the actual security boundary — filtering only the list endpoints controls what the UI *shows*, but a user could still hit this action directly with a known `launch_id` and launch a tile they can't see. Add the same check here, right after the `interaction.nil?` guard:

```ruby
if interaction.nil?
  return render status: :not_found, file: "public/404.html", layout: false
end

permissions = interaction["permissions"]
if permissions.present? && !current_user.ability.user_has_remote_permission?(current_user, backend, permissions)
  return render status: :forbidden, file: "public/403.html", layout: false
end
```

`current_user.ability` is the existing memoized `Ability.new(self)` accessor already defined on `User` (`app/models/user.rb:62-64`).

## Semantics summary

- **Multiple permissions on one interaction**: ANY match — user needs at least one. Matches `user_has_remote_permission?`'s existing behavior, no new logic required.
- **Empty/missing `permissions`**: interaction is visible to all users who pass the existing coarse action-level guard. Fully backward compatible with every interaction defined today.
- **New permission strings**: created manually as `Permission` rows and assigned to `Role`s, same process as today's fixed permission set (e.g. `remote:read:applications`). No auto-sync.

## Testing

- `atomic_admin`: unit test that `Base#resolve` and `Launch#resolve` include `permissions` in their output (extend existing interaction specs).
- `skipper`:
  - `Ability` spec: `user_has_remote_permission?` is now public; add a case where the interaction-style multi-value array grants access via `system_role` and via `BackendAccess` role independently.
  - Controller spec for the shared `interactions` action: a user with only some of the returned interactions' permissions gets a filtered list back; a user with none of them still gets the ones with empty `permissions`.
  - `ExternalLaunchController` spec: launching an interaction the user lacks permission for returns 403; launching one with empty `permissions` (or one they do have) succeeds as before.
