module AtomicAdmin
  class AtomicApplicationsController < ApplicationController
    def index
      @applications = Application.all
      render json: { applications:  json_for_collection(@applications.lti) }
    end

    def show
      @application = Application.find(params[:id])
      render json: { application:  json_for(@application) }
    end

    def update
      @application = Application.find(params[:id])

      # Strong params doesn't allow abritrary json, so we need to set the values manually
      @application.default_config = params[:default_config]
      @application.canvas_api_permissions = params[:canvas_api_permissions]

      @application.update!(application_params)
      render json: { application: json_for(@application) }
    end

    def update_schema
      render json: AtomicAdmin::Schema.for(Application.find(params[:atomic_application_id]))
    end

    private

    def application_params
      params.permit(:name, :description, :oauth_key, :oauth_secret)
    end
  end
end
