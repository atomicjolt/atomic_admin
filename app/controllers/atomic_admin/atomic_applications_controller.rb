# How do we handle customization of these endpoints?
# 1. The tools override the controller and add the custom logic
# 2. The controllers call into the resource's class with the payloads and it handles the details of the implementation

module AtomicAdmin
  class AtomicApplicationsController < ApplicationController
    include Filtering

    allowed_sort_columns %w[name]
    allowed_search_columns %w[name]

    def index
      @applications, meta = filter(Application.all.lti)
      render json: { applications:  json_for_collection(@applications.lti), meta: }
    end

    def show
      @application = Application.find(params[:id])
      render json: { application: json_for(@application) }
    end

    def update
      @application = Application.find(params[:id])

      # Strong params doesn't allow abritrary json, so we need to set the values manually
      @application.default_config = params[:default_config]
      @application.canvas_api_permissions = params[:canvas_api_permissions]

      @application.update!(application_params)
      render json: { application: json_for(@application) }
    end

    def interactions
      application = Application.find(params[:id])
      interactions = AtomicAdmin.application_interactions.resolve(application: application)
      render json: { interactions: interactions }
    end

    private

    def application_params
      params.permit(:name, :description, :oauth_key, :oauth_secret)
    end
  end
end
