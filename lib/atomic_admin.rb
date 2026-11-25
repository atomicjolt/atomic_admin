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
  # When set, the file must exist or the app fails to start
  # (MissingJwksError), and admin_jwks_url isn't used.
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

  # Called once the app has booted. Raises MissingJwksError when
  # admin_jwks_file is set but the file isn't there, so the app fails to start
  # instead of failing admin requests. Skipped while precompiling assets, since
  # Docker builds don't have the mounted file.
  def self.verify_admin_jwks_file!
    return if admin_jwks_file.blank? || running_assets_task?

    AtomicAdmin::JwtToken::JwksDecoder.find_file!(admin_jwks_file)
  end

  def self.running_assets_task?
    defined?(Rake.application) &&
      Rake.application.top_level_tasks.any? { |task| task.start_with?("assets:") }
  end
end
