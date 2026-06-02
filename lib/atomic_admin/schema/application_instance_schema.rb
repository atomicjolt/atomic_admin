
module AtomicAdmin::Schema
  class ApplicationInstanceSchema
    attr_reader :application_instance

    def initialize(application_instance:)
      @application_instance = application_instance
    end

    def schema
      raise "Not implemented"
    end

    def uischema
      raise "Not implemented"
    end
  end
end
