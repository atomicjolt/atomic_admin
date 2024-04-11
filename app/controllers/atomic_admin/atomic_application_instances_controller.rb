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
  end
end
