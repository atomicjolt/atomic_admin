
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
        required: ["nickname", "site_id", "lti_key", "lti_secret", "domain"],
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
          site_id: {
            type: "number",
            label: "Site URL",
            oneOf: sites.map do |site|
              {
                title: site.url,
                const: site.id
              }
            end
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
                type: "Control",
                scope: "#/properties/nickname",
              },
              {
                type: "Control",
                scope: "#/properties/primary_contact",
              },
            ],
          },
          {
            type: "HorizontalLayout",
            elements: [
              {
                type: "Control",
                scope: "#/properties/site_id",
              },
              {
                type: "Control",
                scope: "#/properties/lti_key",
              },
            ]
          }
       ]
      }
    end
  end
end
