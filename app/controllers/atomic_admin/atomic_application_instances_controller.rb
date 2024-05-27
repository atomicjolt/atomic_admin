module AtomicAdmin
  class AtomicApplicationInstancesController < ApplicationController

    def index
      @application_instances = ApplicationInstance.where(application_id: params[:atomic_application_id])
      @application_instances =
        if type == "paid"
          @application_instances.where.not(paid_at: nil)
        else
          @application_instances.where(paid_at: nil)
        end

    if search.present?
      @application_instances = @application_instances.
        where("nickname LIKE ?", "%#{search}%").
        or(@application_instances.where("lti_key LIKE ?", "%#{search}%"))
    end

    order_by =
      if sort_column === "nickname"
        "LOWER(#{sort_column}) #{sort_direction}"
      else
        { sort_column.to_sym => sort_direction.to_sym }
      end

    @application_instances = @application_instances.
      order(order_by).
      paginate(page: params[:page], per_page: 30)

      render json: {
        application_instances: json_for_collection(@application_instances),
        meta: {
          current_page: @application_instances.current_page,
          next_page: @application_instances.next_page,
          prev_page: @application_instances.previous_page,
          total_pages: @application_instances.total_pages,
        }
      }
    end

    def show
      @application_instance = ApplicationInstance.find(params[:id])
      render json: { application_instance: json_for(@application_instance) }
    end

    def create
      instance = ApplicationInstance.new(application_instance_params)

      if instance.save
        render json: { application_instance: json_for(instance) }
      else
        render json: { errors: instance.errors }, status: 422
      end
    end

    def update
      instance = ApplicationInstance.find(params[:id])
      instance.update(application_instance_params)
      byebug

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

    private

    def json_for(instance)
      json = instance.as_json
      json[:site] = instance.site.as_json
      json[:application] = instance.application.as_json

      json
    end

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
      sortable_columns.include?(params[:column]) ? params[:column] : "created_at"
    end

    def sort_direction
      {
        "ascending" => "asc",
        "descending" => "desc",
      }.fetch(params[:direction], "desc")
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
        :license_end_date,
      )
    end
  end
end
