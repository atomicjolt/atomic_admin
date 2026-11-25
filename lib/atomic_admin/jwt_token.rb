require "jwt"
require "httparty"
require_relative 'jwt_token/jwks_decoder'
require_relative 'jwt_token/secret_decoder'

module AtomicAdmin
  module JwtToken
    class InvalidTokenError < StandardError; end
    class MissingTokenError < StandardError; end
    # admin_jwks_file is configured but the file doesn't exist.
    class MissingJwksError < StandardError; end
  end
end
