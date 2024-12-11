module AtomicAdmin
  BASE_CONTROLLER = if AtomicAdmin.authenticating_base_controller_class
                      AtomicAdmin.authenticating_base_controller_class.constantize
                    else
                      AtomicAdmin::AuthenticatingApplicationController
                    end

  class ApplicationController < BASE_CONTROLLER
  end
end
