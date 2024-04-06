module AtomicAdmin
  class ApplicationController < ActionController::API
    include RequireJwtToken
    before_action :only_admins!

    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    def record_not_found
      render json: { message: "Record not found" }, status: 404
    end

    private

    def json_for(resource)
      resource.as_json
    end

    def json_for_collection(collection)
      collection.map { |resource| json_for(resource) }
    end

    def only_admins!
      return if is_atomic_admin?

      user_not_authorized if current_user.blank? && !current_user.admin?
    end

    def user_not_authorized(message = "Not Authorized")
      render json: { message: message, }, status: 401
    end
  end
end
