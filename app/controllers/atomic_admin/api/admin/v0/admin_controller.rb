module AtomicAdmin::Api::Admin::V0
  BASE_CONTROLLER = if AtomicAdmin.authenticating_base_controller_class
                      AtomicAdmin.authenticating_base_controller_class.constantize
                    else
                      AtomicAdmin::Api::Admin::V0::AuthenticatingApplicationController
                    end

  class AdminController < BASE_CONTROLLER
  end
end
