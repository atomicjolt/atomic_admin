module AtomicAdmin::V1
  class ApplicationInstancesController < AdminController
    include AtomicAdmin::Filtering

    allowed_sort_columns %w[nickname]
    allowed_search_columns %w[nickname]

    def index
      @application_instances = ApplicationInstance.where(application_id: params[:application_id])
      @application_instances =
        if type == "paid"
          @application_instances.where.not(paid_at: nil)
        else
          @application_instances.where(paid_at: nil)
        end

      @application_instances, meta = filter(@application_instances)
      @stats = get_stats_for_instances(@application_instances)

      render json: {
        application_instances: json_for_collection(@application_instances),
        meta:
      }
    end

    def show
      @application_instance = ApplicationInstance.find(params[:id])
      @stats = get_stats_for_instances([@application_instance])
      render json: { application_instance: json_for(@application_instance) }
    end

    def create
      application = Application.find(params[:application_id])
      instance = application.application_instances.new(create_params)
      @stats = get_stats_for_instances([instance])

      if instance.save
        render json: { application_instance: json_for(instance) }
      else
        render json: { errors: instance.errors }, status: 422
      end
    end

    def update
      instance = ApplicationInstance.find(params[:id])
      instance.update(update_params)
      @stats = get_stats_for_instances([instance])

      if params[:application_instance][:is_paid] && instance.paid_at.nil?
        instance.paid_at = DateTime.now
      elsif params[:application_instance][:is_paid] == false && instance.paid_at.present?
        instance.paid_at = nil
      end

      if instance.save
        render json: { application_instance: json_for(instance) }
      else
        render json: { errors: instance.errors }, status: 422
      end
    end

    def destroy
      instance = ApplicationInstance.find(params[:id])

      if destroy_instance(instance)
        render json: { success: true }
      else
        render json: { errors: instance.errors }, status: 422
      end
    end

    def interactions
      instance = ApplicationInstance.find(params[:id])
      interactions = AtomicAdmin.application_instance_interactions.resolve(application_instance: instance)
      render json: { interactions: interactions }
    end

    # Host apps store the tenant on an application instance in one of two ways:
    # older schemas have a `tenant` string column, newer ones have `tenant_key`
    # plus a `tenant` association. Returns nil if the app has neither, in which
    # case we skip stats rather than raising.
    def tenant_column
      return @tenant_column if defined?(@tenant_column)

      columns = ApplicationInstance.column_names
      @tenant_column = ["tenant", "tenant_key"].find { |column| columns.include?(column) }&.to_sym
    end

    def get_stats_for_instances(instances)
      return {} if tenant_column.nil?

      tenants = instances.pluck(tenant_column)
      stats = {}
      stats[:errors] = RequestStatistic.total_errors_grouped(tenants) if defined?(RequestStatistic)
      stats[:unique_users] = CachedUniqueUsersByContractDate.unique_users_by_contract_date(instances) if defined?(CachedUniqueUsersByContractDate)
      stats[:max_users_month] = CachedUniqueUsersByMonth.max_monthly_unique_users(instances) if defined?(CachedUniqueUsersByMonth)

      stats
    end

    def request_stats(instance)
      tenant = instance[tenant_column] if tenant_column

      {
        unique_users_in_contract: @stats.dig(:unique_users, tenant) || 0,
        # total_errors_grouped returns one tenant => count hash per window,
        # ordered [today, 7 days, 30 days, 365 days]. These are array indexes,
        # not day counts.
        day_1_errors: @stats.dig(:errors, 0, tenant) || 0,
        day_7_errors: @stats.dig(:errors, 1, tenant) || 0,
        max_users_month: @stats.dig(:max_users_month, tenant) || 0,
      }
    end

    def json_for(instance)
      json = instance.as_json(include: [:application, :site])

      json["trial_start_date"] = instance.trial_start_date&.strftime("%Y-%m-%d") if instance.respond_to?(:trial_start_date)
      json["trial_end_date"] = instance.trial_end_date&.strftime("%Y-%m-%d") if instance.respond_to?(:trial_end_date)
      json["license_start_date"] = instance.license_start_date&.strftime("%Y-%m-%d") if instance.respond_to?(:license_start_date)
      json["license_end_date"] = instance.license_end_date&.strftime("%Y-%m-%d") if instance.respond_to?(:license_end_date)
      json["paid_at"] = instance.paid_at&.strftime("%Y-%m-%d") if instance.respond_to?(:paid_at)
      json["is_paid"] = instance.paid_at.present? if instance.respond_to?(:paid_at)
      json["lti_config_xml"] = instance.lti_config_xml if instance.respond_to?(:lti_config_xml)
      json["request_stats"] = request_stats(instance)

      json
    end

    protected

    # Deletes an application instance.
    #
    # Host apps whose ApplicationInstance implements soft-delete semantics get
    # them automatically. This matters because a hard destroy strands the
    # Apartment tenant schema along with any tenant-keyed data (request
    # statistics and the like), and removes the only row naming that tenant --
    # which hides it from reapers that discover tenants by grouping
    # ApplicationInstance rows, making the orphan permanent rather than delayed.
    #
    # Override this method for anything more involved, such as notifying an
    # external service before deleting.
    #
    # Returns truthy on success. Note that #soft_delete is typically implemented
    # with #update, so it runs validations: an instance that is invalid for
    # unrelated reasons will return false here rather than being deleted.
    def destroy_instance(instance)
      return instance.soft_delete if instance.respond_to?(:soft_delete)

      Rails.logger.warn(
        "AtomicAdmin: #{instance.class} does not respond to #soft_delete, falling back to a hard " \
        "destroy. This may orphan the tenant schema and tenant-keyed data. Define " \
        "#soft_delete on #{instance.class} to opt into soft deletion.",
      )

      instance.destroy
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

    def create_params
      params.require(:application_instance).except(:is_paid, :lti_config_xml, :site, :application, :request_stats).permit!
    end

    def update_params
      create_params
    end
  end
end
