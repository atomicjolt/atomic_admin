require "atomic_admin/version"
require "atomic_admin/engine"
require "atomic_admin/jwt_token"

module AtomicAdmin
  # Base controller class to inherit from. If this is set it is responsible for
  # all authentication
  mattr_accessor :authenticating_base_controller_class, default: nil

  # Before action hooks to allow custom validation
  mattr_accessor :client_id_strategy_before_action, default: nil
  mattr_accessor :platform_guid_strategy_before_action, default: nil
end
