module AtomicAdmin::Interaction
  class Resource < AtomicAdmin::Interaction::Base

    def initialize(controller:, **kwargs)
      super(**kwargs)
      @controller = controller


      Rails.application.config.to_prepare do
        controller_name = controller.demodulize
        AtomicAdmin::Api::Admin::V1.const_set(controller_name, controller.constantize)
      end
    end
  end
end
