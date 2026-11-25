require "atomic_admin/version"
require "atomic_admin/engine"
require "atomic_admin/jwt_token"
require "atomic_admin/schema"
require "atomic_admin/interaction"
require "atomic_admin/role_capabilities/provider"
require "atomic_admin/filtering"

module AtomicAdmin
  mattr_accessor :admin_jwks_url
  # Name of a JWKS file in the app's config directory, e.g. "admin-jwks.json".
  # config/k8s/ (mounted by External Secrets) is checked first, then config/.
  # When set, the file must exist (MissingJwksError otherwise) and
  # admin_jwks_url isn't used.
  mattr_accessor :admin_jwks_file
  mattr_accessor :audience
  mattr_accessor :internal_secret
  mattr_accessor :application_interactions, default: AtomicAdmin::Interaction::Manager.new
  mattr_accessor :application_instance_interactions, default: AtomicAdmin::Interaction::Manager.new
  mattr_accessor :authenticating_base_controller_class, default: nil
  mattr_accessor :client_id_strategy_before_action, default: nil
  mattr_accessor :platform_guid_strategy_before_action, default: nil

  def self.configure
    yield self
  end
end
