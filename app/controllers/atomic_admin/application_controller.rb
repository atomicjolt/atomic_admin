module AtomicAdmin
  class ApplicationController < ActionController::API
    include AtomicAdmin::JwtToken
    # before_action :authenticate_user! # Use validate_token instead for now
     before_action :validate_admin_app_token
     before_action :validate_token
     before_action :only_admins!

     private

     def only_admins!
       return if @admin_app_validated

       user_not_authorized unless current_user.admin?
     end


     def user_not_authorized(message = "Not Authorized")
      render json: { message: message, }, status: 401
    end

  end
end
