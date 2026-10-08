# Interactions

## Permissions

Any interaction type can restrict who sees it by passing `permissions:` — an array of permission strings. A user only sees the interaction if they hold at least one of the listed permissions. An empty or omitted `permissions:` array (the default) means the interaction is visible to everyone who can already access the backend.

```ruby
inter.add(
  :activity_manager,
  type: :launch,
  title: "Activity Manager",
  icon: "launch",
  launch: lambda { |**_| "https://assessments.atomicjolt.xyz/admin/launches/init" },
  aud: config.audience,
  permissions: ["remote:launch:activity_manager"],
)
```

Adding a new permission string here requires creating a matching `Permission` row in skipper and assigning it to the relevant `Role`(s) — otherwise the interaction will be invisible to everyone until that's done.

## `analytics`

Display a custom analytics dashboard.

```ruby
config.application_instance_interactions.tap do |inter|
    inter.add(
      :analytics,
      type: :analytics,
      title: "Analytics",
      icon: "bar_chart",
    )
end
```

## `jsonform`

Display a custom JSON form using [JSONForms](https://jsonforms.io/).

```ruby
config.application_instance_interactions.tap do |inter|
    inter.add(
      :general_settings,
      type: :jsonform,
      title: "General Settings",
      icon: "settings",
      schema: AtomicAdmin::Schema::ApplicationInstanceGeneralSettingsSchema,
    )
end
```

### Pre-defined Schemas

AtomicAdmin provides several pre-defined schemas that can be used with the `jsonform` interaction:

- **ApplicationInstanceGeneralSettingsSchema**: General settings for an application instance, including nickname, primary contact, LMS URL, domain settings, and LTI configurations.

- **ApplicationInstanceLicenseDetailsSchema**: Manage license details including paid status, license dates, number of licensed users, and license type (monthly, yearly, or FTE).

- **ApplicationInstanceTrialDetailsSchema**: Configure trial details including start/end dates, number of trial users, and trial notes.

- **ApplicationInstanceXmlConfigSchema**: Manage LTI 1.1 configurations, including key, secret, and XML configuration.

- **ApplicationInstanceConfigurationSchema**: Edit custom application instance configuration and LTI configuration as JSON.

- **AtomicApplicationUpdateSchema**: Update application settings including description, OAuth key, and OAuth secret.

- **ApplicationInstanceCreateSchema**: Create a new application instance with basic settings like nickname, primary contact, LTI key, and site.

### Creating Custom Schemas

You can create your own schema by defining two methods: `schema` and `uischema`. The `schema` method defines the JSON schema, while the `uischema` method defines the UI schema.

```ruby
class YourCustomSchema
    def schema
        # Define your JSON Schema here
        {
            type: "object",
            properties: {
                field_one: {
                    type: "string",
                    minLength: 1,
                },
                field_two: {
                    type: ["string", "null"],
                },
                # Add more fields as needed
            },
            required: ["field_one"],
        }
    end

    def uischema
        # Define your UI Schema here (layout)
        {
            type: "VerticalLayout",
            elements: [
                {
                    type: "Control",
                    scope: "#/properties/field_one",
                    options: {
                        # Optional formatting options
                        format: "textarea",
                    },
                },
                {
                    type: "Control",
                    scope: "#/properties/field_two",
                },
            ]
        }
    end
end
```

For more complex schemas, you can:

- Use nested layouts with `Group`, `VerticalLayout`, and `HorizontalLayout`
- Add custom formatting with the `options` property
- Define field validation with JSON schema properties like `minLength`, `pattern`, etc.
- Use `oneOf` with mapped values for dropdowns and radio buttons

## `lti_advantage`

Displays a page for managing pinned Client Ids, Deployments, and Platform Instance GUIDS

```ruby
config.application_instance_interactions.tap do |inter|
    inter.add(
      :lti_advantage,
      type: :lti_advantage,
      title: "LTI Advantage",
      icon: "settings",
    )
end
```

## `capabilities`

Lets Skipper edit which roles get which capabilities (role capabilities). Skipper renders a matrix of capabilities by roles; each cell shows what the role grants by default or an override row (`ALLOW`, `DENY` or `PROHIBIT`) at one scope: everywhere, one account or one course.

```ruby
config.application_instance_interactions.tap do |inter|
    inter.add(
      :role_capabilities,
      type: :capabilities,
      title: "Role Capabilities",
      icon: "admin_panel_settings",
      provider: "MyApp::RoleCapabilitiesProvider",
    )
end
```

Registering the interaction adds these routes under each application instance:

- `GET  .../application_instances/:application_instance_id/role_capabilities`: the catalog, roles, override rows and the scopes they use
- `PATCH .../application_instances/:application_instance_id/role_capabilities`: replace one role's rows at one scope, `{ role: { name: }, scope: "global" | "account:<id>" | "course:<context id>", overrides: { capability => mode } }`
- `GET  .../application_instances/:application_instance_id/role_capabilities/scopes?q=`: search accounts and courses

Skipper reads them with `remote:read:applications` and saves with `remote:write:applications`.

The gem's controller reads and writes rows through the host's `RoleCapability` model (`role`, `capability`, `mode`, `context_id`, `account_id`) and `Role` model (`name`), in the application instance's tenant. Everything else comes from the provider: a subclass of `AtomicAdmin::RoleCapabilities::Provider`, named as a string so it reloads in development. The controller builds one per request with `application_instance:`, so the catalog can differ between instances.

```ruby
# app/lib/my_app/role_capabilities_provider.rb
class MyApp::RoleCapabilitiesProvider < AtomicAdmin::RoleCapabilities::Provider
  # Required: [{ name:, group:, label:, description: }] in display order
  def capability_catalog
    Capabilities.catalog
  end

  # Required: the capability names a role grants with no override rows
  def role_defaults(role)
    Capabilities.default_capabilities_for_role(role.name)
  end
end
```

Optional hooks (see `AtomicAdmin::RoleCapabilities::Provider` for their defaults):

- `capability_groups`: `[{ key:, label: }]` naming the catalog's groups, in order
- `role_tiers`, `role_tier(role)`: the default sets roles fall into (`[{ key:, label: }]`, highest first) and each role's tier; columns are ordered by tier
- `listed_roles`: the roles that get a column (every role by default)
- `role_display_name(role)`, `role_kind(role)`: how a role that is not a standard LTI role URI is titled and described
- `custom_roles`, `custom_role?(role)`, `role_for_update(name)`: let roles that have not launched yet be added by name, e.g. `{ label: "Canvas custom role", prefix: "canvas:", example: "Grade Viewer" }`; by default an update must name an existing role
- `account_scopes(ids)`, `course_scopes(context_ids)`, `search_scopes(term)`, `valid_account_id?(id)`: name and find accounts and courses, built with `account_scope_json` and `course_scope_json`. Course scopes cannot be saved until `course_scopes` returns the courses that exist
- `notes`: short notes shown under the matrix, such as how a role's defaults depend on the user's other roles
- `replace_overrides!(role, overrides, context_id:, account_id:)`: how one role's rows at one scope are replaced
