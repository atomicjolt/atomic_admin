
require_relative "schema/atomic_application_update_schema"

module AtomicAdmin
  module Schema
    def self.for(resource, type)
      case [resource.class.name, type]
      when ["Application", "update"]
        schema = AtomicApplicationUpdateSchema.for(resource)
        # schema = Application.update_schema(schema)
        schema
      else
        raise "Unknown resource type: #{resource.class.name}"
      end
    end
  end
end
