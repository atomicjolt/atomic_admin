module RequireJwtToken
   extend ActiveSupport::Concern

  included do
    attr_accessor :auth_source

    before_action :validate_admin_token
    before_action :validate_internal_token
  end

  def is_atomic_admin?
    self.auth_source == :atomic_admin
  end

  def is_internal?
    self.auth_source == :internal
  end

  protected

  def validate_admin_token
    encoded_token = get_encoded_token(request)
    decoder = AtomicAdmin::JwtToken::JwksDecoder.new(AtomicAdmin.admin_jwks_url)
    token = decoder.decode(encoded_token)&.first
    validate_claims!(token)
    self.auth_source = :atomic_admin

    token
  rescue Exception => e
    # Capture all exceptions to let the internal token validation handle it
    Rails.logger.error "Admin JWT Error occured #{e.inspect}"
    nil
  end

  def validate_internal_token
    return if is_atomic_admin?

    encoded_token = get_encoded_token(request)
    decoder = AtomicAdmin::JwtToken::SecretDecoder.new(AtomicAdmin.internal_secret)
    token = decoder.decode!(encoded_token)
    validate_claims!(token)

    current_application_instance_id = request.env['atomic.validated.application_instance_id']
    if current_application_instance_id && current_application_instance_id != token["application_instance_id"]
      raise AtomicAdmin::JwtToken::InvalidTokenError, "Invalid application instance id"
    end

    @user_tenant = token["user_tenant"] if token["user_tenant"].present?
    @user = User.find(token["user_id"])

    sign_in(@user, event: :authentication, store: false)
    self.auth_source = :internal
  rescue JWT::DecodeError, AtomicAdmin::JwtToken::InvalidTokenError => e
    Rails.logger.error "Internal JWT Error occured #{e.inspect}"
    render json: { error: "Unauthorized: Invalid token." }, status: :unauthorized
  end

  private

  def get_encoded_token(req)
    return req.params[:jwt] if req.params[:jwt]

    header = req.headers["Authorization"] || req.headers[:authorization]
    raise AtomicAdmin::JwtToken::MissingTokenError, "No authorization header found" if header.nil?

    token = header.split(" ").last
    raise AtomicAdmin::JwtToken::MissingTokenError, "Invalid authorization header string" if token.nil?

    token
  end

  def validate_claims!(token)
    if AtomicAdmin.audience != token["aud"]
      raise AtomicAdmin::JwtToken::InvalidTokenError, "Expected audience to be #{AtomicAdmin.audience} but was #{token["aud"]}"
    end
  end
end