
module AtomicAdmin::Interaction::AtomicApplicationInstanceInteraction
  def self.get
    sites = Site.all

    [
      {
        type: "analytics",
        title: "Overview",
        icon: "bar_chart",
        key: "analytics",
      },
      {
        type: "jsonform",
        title: "General Settings",
        icon: "edit_note",
        key: "generalSettings",
        schema: {
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
        },
        uischema: {
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
        },
      },
      {
        type: "jsonform",
        title: "Configuration",
        icon: "settings",
        key: "configuration",
        schema: {
          type: "object",
          properties: {
            config: {
              type: "object",
            },
            lti_config: {
              type: "object",
            },
          },
        },
        uischema: {
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
        },
      },
      {
        type: "jsonform",
        title: "XML Configuration",
        icon: "code",
        key: "xmlConfiguration",
        schema: {
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
          },
        },
        uischema: {
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
                    },
                  },
                },
              ],
            },
          ],
        },
      },
      {
        type: "jsonform",
        title: "License Details",
        icon: "payments",
        key: "licenseDetails",
        schema: {
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
        },
        uischema: {
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
        },
      },
      {
        type: "jsonform",
        title: "Trial Details",
        icon: "content_paste",
        key: "trialDetails",
        schema: {
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
        },
        uischema: {
          type: "Group",
          label: "Trial Details",
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
        },
      },
    ]
  end
end
