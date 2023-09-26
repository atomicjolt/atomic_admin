module AtomicAdmin
  class ApplicationController < ActionController::API
    include RequireJwtToken
    before_action :only_admins!

    private

    def only_admins!
      return if is_atomic_admin?

      user_not_authorized if current_user.blank? && !current_user.admin?
    end

    def user_not_authorized(message = "Not Authorized")
      render json: { message: message, }, status: 401
    end

  end
end
