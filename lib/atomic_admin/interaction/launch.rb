module AtomicAdmin::Interaction
  class Launch < AtomicAdmin::Interaction::Base

    def initialize(schema:, **kwargs)
      super(**kwargs)
      @schema_factory = schema
    end

    def resolve(**kwargs)
      hash = super(**kwargs)

      hash[:launch_url] = interaction[:launch_url].call(**kwargs)
      hash[:aud] = interaction[:aud]

      hash
    end
  end
end
