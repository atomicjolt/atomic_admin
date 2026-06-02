module AtomicAdmin::Interaction
  class Readonly < Base
    def initialize(url:, **kwargs)
      super(**kwargs)
      @url = url
    end

    def resolve(**kwargs)
      hash = super(**kwargs)
      hash[:url] = @url.call(**kwargs)
      hash
    end
  end
end
