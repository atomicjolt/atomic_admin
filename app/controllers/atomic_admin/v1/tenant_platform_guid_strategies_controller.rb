module AtomicAdmin::V1
  class TenantPlatformGuidStrategiesController < AdminController
    include AtomicAdmin::Filtering

    allowed_search_columns %w[platform_guid, iss]
    allowed_sort_columns %w[platform_guid, iss]

    def index
      query = AtomicTenant::PinnedPlatformGuid.where(application_instance_id:)
      page, meta = filter(query)

      render json: {
        pinned_platform_guids: page,
        meta:
      }
    end

    def create
      result = AtomicTenant::PinnedPlatformGuid.create!({**create_params, application_instance_id:, application_id:})
      render json: { pinned_platform_guid: result }
    end

    def show
      pinned_platform_guid = find_pinned_platform_guid
      render json: {pinned_platform_guid: pinned_platform_guid}
    end

    def update
      pinned_platform_guid = find_pinned_platform_guid
      pinned_platform_guid.update!(update_params)

      render json: {pinned_platform_guid: find_pinned_platform_guid}
    end

    def destroy
      pinned_platform_guid = find_pinned_platform_guid
      pinned_platform_guid.destroy
      render json: { pinned_platform_guid: pinned_platform_guid }
    end

    protected

    def application_id
      params[:application_id]
    end

    def application_instance_id
      params[:application_instance_id]
    end

    def create_params
      params.require(:pinned_platform_guid).permit!
    end

    def update_params
      params.require(:pinned_platform_guid).permit!
    end

    def find_pinned_platform_guid
      AtomicTenant::PinnedPlatformGuid.find(params[:id])
    end
  end
end
