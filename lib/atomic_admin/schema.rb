
require_relative "schema/atomic_application_update_schema"

module AtomicAdmin
  module Schema
    def self.for(resource)
      case resource.class.name
      when "Application"
        AtomicApplicationUpdateSchema.for(resource)
      else
        raise "Unknown resource type: #{resource.class.name}"
      end
    end
  end
end
