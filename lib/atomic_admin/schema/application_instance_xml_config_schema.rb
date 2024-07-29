module AtomicAdmin::Schema
  class ApplicationInstanceXmlConfigSchema < ApplicationInstanceSchema
    def schema
      {
        type: "object",
        properties: {
          lti_key: {
            type: "string",
          },
          lti_secret: {
            type: "string",
          },
          lti_config_xml: {
            type: "string",
          },
        }
      }
    end

    def uischema
      {
        type: "Group",
        label: "XML Configuration",
        elements: [
          {
            type: "VerticalLayout",
            elements: [
              {
                type: "Control",
                scope: "#/properties/lti_key",
                options: {
                  props: {
                    label: "LTI Key",
                    isReadOnly: true,
                  },
                },
              },
              {
                type: "Control",
                scope: "#/properties/lti_secret",
                options: {
                  props: {
                    label: "LTI Secret",
                    isReadOnly: true,
                  },
                },
              },
              {
                type: "Control",
                scope: "#/properties/lti_config_xml",
                options: {
                  format: "textarea",
                  props: {
                    label: "LTI Config XML",
                    isReadOnly: true,
                    size: "full",
                    rows: 20,
                  },
                },
              },
            ],
          },
        ],
      }
    end
  end
end
