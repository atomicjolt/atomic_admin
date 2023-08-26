module RequireJwtToken
   extend ActiveSupport::Concern

  included do
    before_action :validate_token
  end

  protected

  def validate_token
    encoded_token = get_encoded_token(request)
    token = validate_admin_token(encoded_token)
    if token.present?
      @admin_app_validated = true
      token
    else
      validate_internal_token(encoded_token)
    end
  end

  def validate_admin_token(encoded_token)
    decoder = AtomicAdmin::JwtToken::JwksDecoder.new(AtomicAdmin.admin_jwks_url)
    decoder.decode(encoded_token)&.first
  end

  def validate_internal_token(encoded_token)
    decoder = AtomicAdmin::JwtToken::SecretDecoder.new(AtomicAdmin.internal_secret)
    token = decoder.decode!(request)

    if AtomicAdmin.audience != token["aud"]
      raise AtomicAdmin::JwtToken::InvalidTokenError, "Invalid audience"
    end

    current_application_instance_id = request.env['atomic.validated.application_instance_id']
    if current_application_instance_id && current_application_instance_id != token["application_instance_id"]
      raise AtomicAdmin::JwtToken::InvalidTokenError, "Invalid application instance id"
    end

    @user_tenant = token["user_tenant"] if token["user_tenant"].present?
    @user = User.find(token["user_id"])

    sign_in(@user, event: :authentication, store: false)
  rescue JWT::DecodeError, AtomicAdmin::JwtToken::InvalidTokenError => e
    Rails.logger.error "JWT Error occured #{e.inspect}"
    begin
      render json: { error: "Unauthorized: Invalid token." }, status: :unauthorized
    rescue NoMethodError
      raise RuntimeError, "Unauthorized: Invalid token."
    end
  end

  def get_encoded_token(req)
    return req.params[:jwt] if req.params[:jwt]

    header = req.headers["Authorization"] || req.headers[:authorization]
    raise AtomicAdmin::JwtToken::MissingTokenError, "No authorization header found" if header.nil?

    token = header.split(" ").last
    raise AtomicAdmin::JwtToken::MissingTokenError, "Invalid authorization header string" if token.nil?

    token
  end
end
