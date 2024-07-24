
module AtomicAdmin::Schema
  class ApplicationInstanceTrialDetailsSchema < ApplicationInstanceSchema

    def schema
      {
        type: "object",
        properties: {
          trial_start_date: {
            type: ["string", "null"],
            format: "date-time",
          },
          trial_end_date: {
            type: ["string", "null"],
            format: "date-time",
          },
          trial_users: {
            type: ["number", "null"],
          },
          trial_notes: {
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
                scope: "#/properties/trial_start_date",
                options: {
                  format: "date",
                },
              },
              {
                type: "Control",
                scope: "#/properties/trial_end_date",
                options: {
                  format: "date",
                },
              },
              {
                type: "Control",
                scope: "#/properties/trial_users",
              },
              {
                type: "Control",
                scope: "#/properties/trial_notes",
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
