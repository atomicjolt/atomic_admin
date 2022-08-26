module AtomicAdmin
  module JwtToken
 
    ALGORITHM = "HS512".freeze

    class InvalidTokenError < StandardError; end

    def self.valid?(token, secret = nil, algorithm = ALGORITHM)
      decode(token, secret, true, algorithm)
    end

    def self.decode(token, secret = nil, validate = true, algorithm = ALGORITHM)
      JWT.decode(
        token,
        secret || Rails.application.secrets.auth0_client_secret,
        validate,
        { algorithm: algorithm },
      )
    end

    def decoded_jwt_token(req, secret = nil)
      token = AtomicAdmin::JwtToken.valid?(encoded_token(req), secret)
      raise InvalidTokenError, "Unable to decode jwt token" if token.blank?
      raise InvalidTokenError, "Invalid token payload" if token.empty?

      token[0]
    end
 
    def validate_token
      token = decoded_jwt_token(request)
      raise InvalidTokenError if Rails.application.secrets.auth0_client_id != token["aud"]
  
      current_application_instance = request.env['atomic.validated.application_instance_id']
      if current_application_instance && current_application_instance.id != token["application_instance_id"]
        raise InvalidTokenError
      end
  
      @user_tenant = token["user_tenant"] if token["user_tenant"].present?
      switch_tenant_if_welcome do
        @user = User.find(token["user_id"])
      end
  
      sign_in(@user, event: :authentication, store: false)
    rescue JWT::DecodeError, InvalidTokenError => e
      Rails.logger.error "JWT Error occured #{e.inspect}"
      begin
        render json: { error: "Unauthorized: Invalid token." }, status: :unauthorized
      rescue NoMethodError
        raise GraphQL::ExecutionError, "Unauthorized: Invalid token."
      end
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