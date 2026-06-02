require_relative 'jwt_token/jwks_decoder'
require_relative 'jwt_token/secret_decoder'

module AtomicAdmin
  module JwtToken
    class InvalidTokenError < StandardError; end
    class MissingTokenError < StandardError; end
  end
end
