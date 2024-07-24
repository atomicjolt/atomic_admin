
module AtomicAdmin::Schema
  class ApplicationInstanceLicenseDetailsSchema < ApplicationInstanceSchema

    def schema
      {
        type: "object",
        properties: {
          license_start_date: {
            type: ["string", "null"],
            format: "date-time",
          },
          license_end_date: {
            type: ["string", "null"],
            format: "date-time",
          },
          licensed_users: {
            type: ["number", "null"],
          },
          license_type: {
            type: ["string", "null"],
            oneOf: [
              {
                title: "Monthly",
                const: "monthly",
              },
              {
                title: "Annual",
                const: "annual",
              },
              {
                title: "FTE",
                const: "fte",
              },
            ],
          },
          license_notes: {
            type: ["string", "null"],
          },
        },
      }
    end

    def uischema
      {
        type: "Group",
        label: "License Details",
        elements: [
          {
            type: "VerticalLayout",
            elements: [
              {
                type: "Control",
                scope: "#/properties/license_start_date",
                options: {
                  format: "date",
                },
              },
              {
                type: "Control",
                scope: "#/properties/license_end_date",
                options: {
                  format: "date",
                },
              },
              {
                type: "Control",
                scope: "#/properties/licensed_users",
              },
              {
                type: "Control",
                scope: "#/properties/license_type",
                options: {
                  format: "radio",
                },
              },
              {
                type: "Control",
                scope: "#/properties/license_notes",
                options: {
                  format: "textarea",
                },
              },
            ],
          },
        ],
      }
    end
  end
end
