module AtomicAdmin::JwtToken
  # Decodes a JWT token using the JWKS endpoint
  # This is used for decoding JWT tokens issued by the new
  # admin app
  class JwksDecoder
    ALGORITHMS = ["RS256"].freeze

    def initialize(jwks_url, algorithms = ALGORITHMS)
      @jwks_url = jwks_url
      @algorithms = algorithms
    end

    def decode(token, validate = true)
      load_admin_jwks = ->(options) do
        Rails.cache.delete("atomic_admin_jwks") if options[:kid_not_found]

        # NOTE: the cached keys only expire when we recieve a kid_not_found error
        keys = Rails.cache.fetch("atomic_admin_jwks") do
          HTTParty.get(@jwks_url).parsed_response
        end

        JWT::JWK::Set.new(keys).select { |k| k[:use] == "sig" }
      end

      JWT.decode(
        token,
        nil,
        validate,
        { algorithms: @algorithms, jwks: load_admin_jwks },
      )
    end

    def decode!(token)
      token = decode(token)
      raise AtomicAdmin::JwtToken::InvalidTokenError, "Unable to decode jwt token" if token.blank?
      raise AtomicAdmin::JwtToken::InvalidTokenError, "Invalid token payload" if token.empty?

      token[0]
    end
  end
end
