module AtomicAdmin::Interaction
  class JsonForm < AtomicAdmin::Interaction::Base

    def initialize(schema:, **kwargs)
      super(**kwargs)
      @schema_factory = schema
    end

    def resolve(**kwargs)
      hash = super(**kwargs)

      schema = @schema_factory.new(**kwargs)
      hash[:schema] = schema.schema
      hash[:uischema] = schema.uischema

      hash
    end
  end
end
