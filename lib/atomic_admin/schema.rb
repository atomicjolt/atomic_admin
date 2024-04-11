
require_relative "schema/atomic_application_update_schema"

module AtomicAdmin
  module Schema
    def self.for(resource, type)
      case [resource.class.name, type]
      when ["Application", "update"]
        AtomicApplicationUpdateSchema.for(resource)
      else
        raise "Unknown resource type: #{resource.class.name}"
      end
    end
  end
end
