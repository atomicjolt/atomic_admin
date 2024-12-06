
module AtomicAdmin::Schema
  class ApplicationInstanceLicenseDetailsSchema < ApplicationInstanceSchema

    def schema
      {
        type: "object",
        properties: {
          is_paid: {
            type: "boolean",
            title: "Paid Account"
          },
          license_start_date: {
            type: ["string", "null"],
            format: "date",
          },
          license_end_date: {
            type: ["string", "null"],
            format: "date",
          },
          licensed_users: {
            type: ["number", "null"],
            minimum: 0,
          },
          license_type: {
            type: ["string", "null"],
            oneOf: [
              {
                title: "Monthly",
                const: "monthly",
              },
              {
                title: "Yearly",
                const: "yearly",
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
                scope: "#/properties/is_paid",
              },
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
