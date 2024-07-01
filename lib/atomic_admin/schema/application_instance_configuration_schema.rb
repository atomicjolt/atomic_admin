module AtomicAdmin::Schema
  class ApplicationInstanceConfigurationSchema < ApplicationInstanceSchema
    def schema
      {
        type: "object",
        properties: {
          config: {
            type: "object",
          },
          lti_config: {
            type: "object",
          },
        },
      }
    end

    def uischema
      {
        type: "VerticalLayout",
        elements: [
          {
            type: "Group",
            label: "Custom App Instance Configuration",
            elements: [
              {
                type: "Control",
                scope: "#/properties/config",
                options: {
                  format: "json",
                  props: {
                    size: "full",
                    label: "",
                    height: "400px",
                  },
                },
              },
            ],
          },
          {
            type: "Group",
            label: "LTI Config",
            elements: [
              {
                type: "Control",
                scope: "#/properties/lti_config",
                options: {
                  format: "json",
                  props: {
                    size: "full",
                    label: "",
                    height: "400px",
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
