module AtomicAdmin::JwtToken
  # Decodes a JWT token issued by the admin app (Skipper) using its JWKS.
  #
  # When `jwks_file` is set, the JWKS is read from that file in the app's
  # config directory, looking in config/k8s/ first (where External Secrets
  # mounts it when deployed) and then config/, the same way the apps'
  # ConfigLoader finds their settings. If neither exists, MissingJwksError is
  # raised. Without `jwks_file`, the JWKS is fetched from `jwks_url` and cached
  # until a token arrives with an unknown kid.
  class JwksDecoder
    ALGORITHMS = ["RS256"].freeze
    CACHE_KEY = "atomic_admin_jwks".freeze

    def initialize(jwks_url, algorithms = ALGORITHMS, jwks_file: nil)
      @jwks_url = jwks_url
      @jwks_file = jwks_file
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
      return JSON.parse(File.read(jwks_file_path)) if @jwks_file.present?

      Rails.cache.delete(CACHE_KEY) if options[:kid_not_found]

      # NOTE: the cached keys only expire when we recieve a kid_not_found error
      Rails.cache.fetch(CACHE_KEY) do
        HTTParty.get(@jwks_url).parsed_response
      end
    end

    def jwks_file_path
      config = Rails.configuration.paths["config"].existent.first
      candidates = ["#{config}/k8s/#{@jwks_file}", "#{config}/#{@jwks_file}"]
      candidates.find { |path| File.file?(path) } ||
        raise(MissingJwksError, "Admin JWKS file not found, looked in: #{candidates.join(', ')}")
    end
  end
end
