module AtomicAdmin::JwtToken
  # Decodes a JWT token using a known secret. This is used for decoding
  # JWT tokens issued by the application itself for the old admin app
  class SecretDecoder
    ALGORITHM = "HS512".freeze

    def initialize(secret, algorithm = ALGORITHM)
      @secret = secret
      @algorithm = algorithm
    end

    def decode(token, validate = true)
      JWT.decode(
        token,
        @secret,
        validate,
        { algorithm: @algorithm },
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
