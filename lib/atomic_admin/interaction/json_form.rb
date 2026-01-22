module AtomicAdmin::Interaction
  class JsonForm < AtomicAdmin::Interaction::Base

    def initialize(launch:, aud:, **kwargs)
      super(**kwargs)
      @launch = launch
      @aud = aud
    end

    def resolve(**kwargs)
      hash = super(**kwargs)

      hash[:launch_url] = @launch.call(**kwargs)
      hash[:aud] = @aud

      hash
    end
  end
end
