module AtomicAdmin::Interaction
  class Analytics < AtomicAdmin::Interaction::Base

    def initialize(controller:, **kwargs)
      super(**kwargs)
      @controller = controller

      Rails.application.config.to_prepare do
        AtomicAdmin::Api::Admin::V1.const_set(:StatsController, @controller.constantize)
      end
    end
  end
end
