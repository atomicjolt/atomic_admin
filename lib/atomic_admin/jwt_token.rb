## Note: This code is basically copied out of the starter app to authenticate
##        admin app api calls. Lives at /app/controllers/concerns/jwt_token.rb in
##        starter app
module AtomicAdmin
  module JwtToken

    ALGORITHM = "RS256".freeze

    class InvalidTokenError < StandardError; end

    def self.valid?(token, algorithm = ALGORITHM)
      decode(token, secret, true, algorithm)
    end

    def self.decode(token, validate = true, algorithm = ALGORITHM)

      load_admin_jwks = ->(options) do
        Rails.cache.delete("atomic_admin_jwks") if options[:kid_not_found]

        # NOTE: the cached keys only expire when we recieve a kid_not_found error
        keys = Rails.cache.fetch("atomic_admin_jwks") do
          jwks_raw = Net::HTTP.get URI(AtomicAdmin.admin_jwks_url)
          JSON.parse(jwks_raw)
        end

        JWT::JWK::Set.new(keys).select { |k| k[:use] == "sig" }
      end

      JWT.decode(
        token,
        nil,
        validate,
        { algorithms: [algorithm], jwks: load_admin_jwks },
      )
    end

    def decoded_jwt_token(req, secret = nil)
      token = AtomicAdmin::JwtToken.valid?(encoded_token(req))
      raise InvalidTokenError, "Unable to decode jwt token" if token.blank?
      raise InvalidTokenError, "Invalid token payload" if token.empty?

      token[0]
    end

    def validate_token
      return if @admin_app_validated

      token = decoded_jwt_token(request)
      raise InvalidTokenError if AtomicAdmin.audience != token["aud"]

      current_application_instance_id = request.env['atomic.validated.application_instance_id']
      if current_application_instance_id && current_application_instance_id != token["application_instance_id"]
        raise InvalidTokenError
      end

      @user_tenant = token["user_tenant"] if token["user_tenant"].present?
      @user = User.find(token["user_id"])

      sign_in(@user, event: :authentication, store: false)
    rescue JWT::DecodeError, InvalidTokenError => e
      Rails.logger.error "JWT Error occured #{e.inspect}"
      begin
        render json: { error: "Unauthorized: Invalid token." }, status: :unauthorized
      rescue NoMethodError
        raise RuntimeError, "Unauthorized: Invalid token."
      end
    end

    def validate_admin_app_token
      _bearer, jwt = request.headers['Authorization'].split(' ')
      @atomic_admin_params = AtomicAdmin::JwtToken.decode(jwt)
      @admin_app_validated = true
    rescue JWT::DecodeError, InvalidTokenError => e
      # fall back to regular app jwt
      Rails.logger.error "JWT Error occured with admin app token #{e.inspect}"
      @admin_app_validated = false
    end

    protected

    def encoded_token(req)
      return req.params[:jwt] if req.params[:jwt]

      header = req.headers["Authorization"] || req.headers[:authorization]
      raise InvalidTokenError, "No authorization header found" if header.nil?

      token = header.split(" ").last
      raise InvalidTokenError, "Invalid authorization header string" if token.nil?

      token
    end
  end
end
