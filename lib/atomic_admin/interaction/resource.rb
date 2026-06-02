module AtomicAdmin::Interaction
  class Resource < AtomicAdmin::Interaction::Base

    def initialize(controller:, table:, actions: [], plural:, singular:, **kwargs)
      super(**kwargs)
      @controller = controller
      @table = table
      @actions = actions
      @plural = plural
      @singular = singular

      Rails.application.config.to_prepare do
        controller_name = controller.demodulize
        AtomicAdmin::Api::Admin::V1.const_set(controller_name, controller.constantize)
      end
    end

    def resolve(**kwargs)
      hash = super(**kwargs)

      hash[:plural] = @plural
      hash[:singular] = @singular
      hash[:table] = @table

      hash[:actions] = @actions.map do |action|
        action_hash = {
          type: action[:type],
          label: action[:label],
        }

        if action[:schema]
          schema_factory = action[:schema]
          schema = schema_factory.new(**kwargs)

          action_hash[:schema] = schema.schema
          action_hash[:uischema] = schema.uischema
        end

        action_hash
      end

      hash
    end
  end
end
