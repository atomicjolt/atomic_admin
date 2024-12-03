module AtomicAdmin
  class AtomicApplicationInstancesController < ApplicationController
    include Filtering

    allowed_sort_columns %w[nickname]
    allowed_search_columns %w[nickname]

    def index
      @application_instances = ApplicationInstance.where(application_id: params[:atomic_application_id])
      @application_instances =
        if type == "paid"
          @application_instances.where.not(paid_at: nil)
        else
          @application_instances.where(paid_at: nil)
        end

      @application_instances, meta = filter(@application_instances)

      render json: {
        application_instances: json_for_collection(@application_instances),
        meta:
      }
    end

    def show
      @application_instance = ApplicationInstance.find(params[:id])
      render json: { application_instance: json_for(@application_instance) }
    end

    def create
      application = Application.find(params[:atomic_application_id])
      instance = application.application_instances.new(application_instance_params)

      if instance.save
        render json: { application_instance: json_for(instance) }
      else
        render json: { errors: instance.errors }, status: 422
      end
    end

    def update
      instance = ApplicationInstance.find(params[:id])
      instance.update(application_instance_params)

      instance.update(
        config: params[:config],
        lti_config: params[:lti_config],
      )

      if params[:is_paid] && instance.paid_at.nil?
        instance.paid_at = DateTime.now
      elsif params[:is_paid] == false && instance.paid_at.present?
        instance.paid_at = nil
      end


      if instance.save
        render json: { application_instance: json_for(instance) }
      else
        render json: { errors: instance.errors }, status: 422
      end
    end

    def interactions
      instance = ApplicationInstance.find(params[:id])
      interactions = AtomicAdmin.application_instance_interactions.resolve(application_instance: instance)
      render json: { interactions: interactions }
    end

    def json_for(instance)
      json = instance.as_json(include: [:application, :site])

      json["trial_start_date"] = instance.trial_start_date&.strftime("%Y-%m-%d")
      json["trial_end_date"] = instance.trial_end_date&.strftime("%Y-%m-%d")
      json["license_start_date"] = instance.license_start_date&.strftime("%Y-%m-%d")
      json["license_end_date"] = instance.license_end_date&.strftime("%Y-%m-%d")
      json["is_paid"] = instance.paid_at.present?

      json
    end

    private

    def sortable_columns
      [
        "created_at",
        "trial_end_date",
        "trial_users",
        "license_end_date",
        "licensed_users",
        "nickname",
      ]
    end

    def sort_column
      sortable_columns.include?(params[:sort_on]) ? params[:sort_on] : "created_at"
    end

    def sort_direction
      {
        "ascending" => "asc",
        "descending" => "desc",
      }.fetch(params[:sort_direction], "desc")
    end

    def type
      params[:type] == "paid" ? "paid" : "evals"
    end

    def search
      params[:search]
    end

    def application_instance_params
      params.permit(
        :site_id,
        :lti_secret,
        :lti_key,
        :canvas_token,
        :disabled_at,
        :anonymous,
        :rollbar_enabled,
        :paid_at,
        :domain,
        :use_scoped_developer_key,
        :language,
        :nickname,
        :primary_contact,
        :trial_notes,
        :trial_users,
        :trial_end_date,
        :trial_start_date,
        :license_type,
        :license_notes,
        :licensed_users,
        :license_start_date,
        :license_end_date,
      )
    end
  end
end
