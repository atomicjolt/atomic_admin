module AtomicAdmin
  class ApplicationController < ActionController::API
    include RequireJwtToken
    before_action :only_admins!

    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    def record_not_found
      render_error(:not_found)
    end

    private

    def render_error(type, message: nil)
      case type
      when :not_found
        [404, { type: "not_found", message: "Record not found" }]
      else
        [500, { type: "unknown", message: "An error occurred" }]
      end => [status, error]

      if message.present?
        error[:message] = message
      end

      render json: error, status: status
    end

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
