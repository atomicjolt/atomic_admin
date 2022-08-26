module AtomicAdmin
  class ApplicationController < ActionController::API 
    include AtomicAdmin::JwtToken
    # before_action :authenticate_user!
     before_action :validate_token
     before_action :only_admins!

     private

     def only_admins!
       user_not_authorized unless current_user.admin?
     end


     def user_not_authorized(message = "Not Authorized")
      render json: { message: message, }, status: 401 
    end

  end
end
