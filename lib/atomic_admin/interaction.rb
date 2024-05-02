module AtomicAdmin::Interaction
  module Manager
    @@classes = []

    def self.register(klass)
      @@classes << klass
    end

    def self.for(group, **kwargs)
      @@key_map ||= @@classes.index_by do |klass|
        klass.class_variable_get(:@@key)
      end

      group_classes = @@key_map.values.select do |klass|
        klass.class_variable_get(:@@group) == group && klass.class_variable_get(:@@enabled)
      end.sort do |a, b|
        a.class_variable_get(:@@order) <=> b.class_variable_get(:@@order)
      end


      group_classes.map do |klass|
        type = klass.class_variable_get(:@@type)
        hash = {
          type: type,
          title: klass.class_variable_get(:@@title),
          icon: klass.class_variable_get(:@@icon),
          key: klass.class_variable_get(:@@key),
        }

        case type
        when :jsonform
          instance = klass.new(**kwargs)
          hash[:schema] = instance.schema
          hash[:uischema] = instance.uischema
        end

        hash
      end
    end
  end

  require_relative "interaction/base_interaction"
  require_relative "interaction/analytics_interaction"
  require_relative "interaction/general_settings_interaction"
end
