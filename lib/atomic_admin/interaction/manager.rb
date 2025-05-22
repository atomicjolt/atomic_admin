module AtomicAdmin::Interaction
  class Manager
    include Enumerable

    INTERACTIONS = {
      analytics: AtomicAdmin::Interaction::Analytics,
      jsonform: AtomicAdmin::Interaction::JsonForm,
      resource: AtomicAdmin::Interaction::Resource,
    }.freeze

    def initialize
      @interactions = {}
      @curr_index = 0
    end

    def each(&block)
      @interactions.each do |key, interaction|
        block.call(key, interaction)
      end
    end

    def add(key, type:, **kwargs)
      interaction_cls = INTERACTIONS[type] || AtomicAdmin::Interaction::Base

      interaction = interaction_cls.new(key:, type:, order: @curr_index, **kwargs)
      @interactions[key] = interaction
      @curr_index += 1

      nil
    end

    def get(key)
      @interactions[key]
    end

    def [](key)
      @interactions[key]
    end

    def tap
      yield self
      self
    end

    def for_type(type)
      @interactions.values.select { |interaction| interaction.type == type }
    end


    def as_json(**kwargs)
      sorted = @interactions.sort_by { |key, interaction| interaction.order }
      sorted.map do |key, interaction|
        interaction.resolve(**kwargs)
      end
    end

    alias resolve as_json
  end
end
