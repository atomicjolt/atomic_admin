class AtomicAdmin::Interaction::GeneralSettingsInteraction < AtomicAdmin::Interaction::BaseInteraction
  group :application_instances
  key :general_settings
  type :jsonform
  title "General Settings"
  icon "settings"
  order 1

  def schema
    sites = Site.all

    {
      type: "object",
      properties: {
        nickname: {
          type: "string",
          minLength: 1,
        },
        primary_contact: {
          type: ["string", "null"],
        },
        created_at: {
          type: "string",
          format: "date-time",
        },
        lti_key: {
          type: "string",
        },
        lti_secret: {
          type: "string",
        },
        #  The available sites is based on the sites that have been created
        #  so this would require it to be dynamically generated on the fly
        site_id: {
          type: "string",
          oneOf: sites.map do |site|
            {
              title: site.url,
              const: site.id.to_s,
            }
          end
        },
        domain: {
          type: "string",
        },
        canvas_token: {
          type: ["string", "null"],
        },
        rollbar_enabled: {
          type: "boolean",
        },
        use_scoped_developer_key: {
          type: "boolean",
        },
      },
      required: ["nickname"],
    }
  end

  def uischema
    {
      type: "HorizontalLayout",
      elements: [
        {
          type: "Group",
          label: "General Settings",
          elements: [
            {
              type: "VerticalLayout",
              elements: [
                {
                  type: "Control",
                  scope: "#/properties/nickname",
                },
                {
                  type: "Control",
                  scope: "#/properties/primary_contact",
                },
                {
                  type: "Control",
                  scope: "#/properties/created_at",
                  label: "Date Created",
                  options: {
                    format: "date",
                    props: {
                      isReadOnly: true,
                      size: "small",
                    },
                  },
                },
                {
                  type: "Control",
                  scope: "#/properties/site_id",
                  label: "LMS URL",
                  options: {
                    props: {
                      menuSize: "auto",
                    }
                  }
                },
                {
                  type: "Control",
                  scope: "#/properties/domain",
                  label: "LTI Tool Domain",
                },
                {
                  type: "Control",
                  scope: "#/properties/canvas_token",
                  label: "Canvas Token",
                  options: {
                    props: {
                      message: "Current Canvas Token: null",
                    },
                  },
                },
                {
                  type: "Control",
                  scope: "#/properties/rollbar_enabled",
                  label: "Enable Rollbar",
                },
                {
                  type: "Control",
                  scope: "#/properties/use_scoped_developer_key",
                  label: "Use Scoped Developer Key",
                },
              ],
            },
          ],
        },
        {
          type: "Group",
          label: "LTI Key and Secret",
          elements: [
            {
              type: "VerticalLayout",
              elements: [
                {
                  type: "Control",
                  scope: "#/properties/lti_key",
                  label: "LTI Key",
                  options: {
                    props: {
                      isReadOnly: true,
                    },
                  },
                },
                {
                  type: "Control",
                  scope: "#/properties/lti_secret",
                  label: "LTI Secret",
                },
              ],
            },
          ],
        },
      ],
    }
  end
end
