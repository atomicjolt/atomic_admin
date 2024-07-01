module AtomicAdmin::Interaction
  class Manager
    def initialize
      @interactions = {}
      @curr_index = 0
    end

    def add(key, **kwargs)
      @interactions[key] = {
        **kwargs,
        order: @curr_index,
      }
      @curr_index += 1
    end

    def get(key)
      @interactions[key]
    end

    def tap
      yield self
      self
    end

    def resolve(**kwargs)
      sorted = @interactions.sort_by { |key, interaction| interaction[:order] }
      sorted.map do |key, interaction|
        type = interaction[:type]
        hash = {
          key: key,
          type: type,
          title: interaction[:title],
          icon: interaction[:icon],
        }

        case type
        when :jsonform
          schema_factory = interaction[:schema]
          schema = schema_factory.new(**kwargs)
          hash[:schema] = schema.schema
          hash[:uischema] = schema.uischema
        end

        hash
      end
    end
  end
end
