module AtomicAdmin::V1
  class ApplicationsController < AdminController
    include Filtering

    allowed_sort_columns %w[name]
    allowed_search_columns %w[name]

    def index
      @applications, meta = filter(Application.all.lti)
      render json: { applications:  json_for_collection(@applications), meta: }
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

      @application.update!(update_params)
      render json: { application: json_for(@application) }
    end

    def interactions
      application = Application.find(params[:id])
      interactions = AtomicAdmin.application_interactions.resolve(application: application)
      render json: { interactions: interactions }
    end

    def json_for(application)
      json = application.as_json.with_indifferent_access
      secret = json[:oauth_secret]
      json[:oauth_secret_preview] = secret[0..2] + '*' * (secret.length - 3) if secret

      json
    end

    protected

    def update_params
      params.require(:application).permit!
    end
  end
end
