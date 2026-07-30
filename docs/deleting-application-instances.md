# Deleting Application Instances

`DELETE /api/admin/v1/applications/:application_id/application_instances/:id`
soft-deletes the instance when the host app supports it, and hard-destroys it
otherwise.

## Soft delete is automatic

If your `ApplicationInstance` responds to a public `soft_delete` method, the
engine calls it instead of `destroy`:

```ruby
class ApplicationInstance < ApplicationRecord
  default_scope { where(deleted_at: nil) }

  def soft_delete
    update(deleted_at: Time.now)
  end
end
```

No configuration is required — implementing the method is the opt-in.

## Why this matters for multi-tenant apps

For an app that gives each application instance its own Apartment tenant, a hard
destroy is lossy in a way that is easy to miss:

- The tenant schema is **not** dropped. Nothing in the engine drops it, and any
  `destroy_schema` the host defines is not wired to a `before_destroy` hook.
- Tenant-keyed data that is not an ActiveRecord association — request statistics
  and similar tables keyed by a `tenant` string — is left behind, because
  `dependent: :destroy` does not reach it.
- Most importantly, the orphan becomes **permanent**. Reapers typically discover
  stale tenants by grouping `ApplicationInstance` rows by `tenant` (see
  `purge_old_tenants` in atomic-search and atomic-assessments). A hard destroy
  removes the only row naming that tenant, so the tenant is invisible to the one
  process that would have cleaned it up. Soft deletion leaves the row behind with
  `deleted_at` set, which is exactly what those reapers key on.

If your `ApplicationInstance` has associations that live in the tenant schema
rather than the public one, note that the engine does not switch tenants before
deleting, so `dependent: :destroy` on those associations runs against whichever
schema is currently active. Handle that inside `soft_delete` or an override.

## Validation failures are reported

`soft_delete` is usually implemented with `update`, which runs validations —
unlike `destroy`, which skips them. An instance that is invalid for unrelated
reasons therefore cannot be soft-deleted. The engine honors the return value and
responds `422` with the record's errors rather than reporting success:

```json
{ "errors": { "language": ["can't be blank"] } }
```

Successful deletes continue to respond `200` with `{ "success": true }`.

## Overriding

For anything more involved than `soft_delete` — notifying an external service,
enqueueing offboarding work — override the protected `destroy_instance` method
rather than the whole `destroy` action, so the response and error handling stay
consistent:

```ruby
# app/controllers/atomic_admin/api/admin/v1/application_instances_controller.rb

class AtomicAdmin::Api::Admin::V1::ApplicationInstancesController < AtomicAdmin::V1::ApplicationInstancesController
  protected

  def destroy_instance(instance)
    MyService.begin_offboarding(instance)
    super
  end
end
```

Return a truthy value on success and a falsy one on failure. If the host app
defines neither `soft_delete` nor an override, the engine hard-destroys the
record and logs a warning.
