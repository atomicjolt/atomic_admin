
module AtomicAdmin::Schema
  class AtomicApplicationUpdateSchema
    attr_accessor :application

    def initialize(application)
      @application = application
    end

    def schema
      {
        type: "object",
        properties: {
          description: {
            type: "string",
          },
          oauth_key: {
            type: ["string", "null"],
          },
          oauth_secret: {
            type: ["string", "null"],
          },
          default_config: {
            type: "object",
          },
          canvas_api_permissions: {
            type: "object",
          },
        }
      }
    end

    def uischema
      {
        type: "VerticalLayout",
        elements: [
          {
            type: "Control",
            scope: "#/properties/description",
            options: {
              format: "textarea",
              props: {
                size: "full",
                resize: "vertical"
              }
            }
          },
          {
            type: "Control",
            scope: "#/properties/oauth_key",
          },
          {
            type: "Control",
            scope: "#/properties/oauth_secret",
          },
          {
            type: "Control",
            scope: "#/properties/default_config",
            options: {
              format: "json",
              props: {
                size: "full"
              }
            }
          },
          {
            type: "Control",
            scope: "#/properties/canvas_api_permissions",
            options: {
              format: "json",
              props: {
                size: "full"
              }
            }
          },
        ]
      }
    end
  end
end
