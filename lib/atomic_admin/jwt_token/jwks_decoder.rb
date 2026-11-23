module AtomicAdmin::JwtToken
  # Decodes a JWT token issued by the admin app (Skipper) using its JWKS.
  #
  # The JWKS is read from a local file when `jwks_path` points at one (for
  # example a file mounted by External Secrets). Otherwise it is fetched from
  # `jwks_url` and cached until a token arrives with an unknown kid.
  class JwksDecoder
    ALGORITHMS = ["RS256"].freeze
    CACHE_KEY = "atomic_admin_jwks".freeze

    def initialize(jwks_url, algorithms = ALGORITHMS, jwks_path: nil)
      @jwks_url = jwks_url
      @jwks_path = jwks_path
      @algorithms = algorithms
    end

    def decode(token, validate = true)
      load_admin_jwks = ->(options) do
        JWT::JWK::Set.new(admin_jwks(options)).select { |k| k[:use] == "sig" }
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

    private

    def admin_jwks(options)
      # The file is small and gets replaced in place when the keys rotate, so
      # it is read on every call instead of being cached.
      return JSON.parse(File.read(@jwks_path)) if jwks_file?

      Rails.cache.delete(CACHE_KEY) if options[:kid_not_found]

      # NOTE: the cached keys only expire when we recieve a kid_not_found error
      Rails.cache.fetch(CACHE_KEY) do
        HTTParty.get(@jwks_url).parsed_response
      end
    end

    def jwks_file?
      @jwks_path.present? && File.exist?(@jwks_path)
    end
  end
end
