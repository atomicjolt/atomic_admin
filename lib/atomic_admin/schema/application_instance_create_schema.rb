
module AtomicAdmin::Schema
  class ApplicationInstanceCreateSchema
    attr_accessor :application

    def initialize(application)
      @application = application
    end

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
          lti_key: {
            type: "string",
          },
          lti_secret: {
            type: "string",
          },
          site_id: {
            type: "number",
            oneOf: sites.map do |site|
              {
                title: site.url,
                const: site.id
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
          paid_account: {
            type: "boolean",
          },
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
            type: "HorizontalLayout",
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
                    scope: "#/properties/site_id",
                  },
                  {
                    type: "Control",
                    scope: "#/properties/lti_key",
                  },
                  {
                    type: "Control",
                    scope: "#/properties/canvas_token",
                  },
                ],
              },
              {
                type: "VerticalLayout",
                elements: [
                  {
                    type: "Control",
                    scope: "#/properties/primary_contact",
                  },
                  {
                    type: "Control",
                    scope: "#/properties/domain",
                  },
                  {
                    type: "Control",
                    scope: "#/properties/lti_secret",
                  },
                ],
              },
            ]
          },
          {
            type: "Control",
            scope: "#/properties/rollbar_enabled",
          },
          {
            type: "Control",
            scope: "#/properties/use_scoped_developer_key",
          },
          {
            type: "Control",
            scope: "#/properties/paid_account",
          },
          {
            type: "Control",
            scope: "#/properties/config",
            options: {
              format: "json",
              props: {
                size: "full",
                height: "200px",
                defaultValue: "{}"
              },
            },
          },
          {
            type: "Control",
            scope: "#/properties/lti_config",
            options: {
              format: "json",
              props: {
                size: "full",
                height: "200px",
                defaultValue: "{}"
              },
            },
          },
        ]
      }
    end
  end
end
