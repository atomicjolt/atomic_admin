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
            secret: {
              preview: "ouath_secret_preview",
              value: "oauth_secret"
            }
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
        ]
      }
    end
  end
end
