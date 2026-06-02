# Interactions

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
