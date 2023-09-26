require "atomic_admin/version"
require "atomic_admin/engine"
require "atomic_admin/jwt_token"

module AtomicAdmin
  mattr_accessor :admin_jwks_url
  mattr_accessor :audience
  mattr_accessor :internal_secret
end
