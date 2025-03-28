module AtomicAdmin::V1
  class TenantPlatformGuidStrategiesController < AdminController
    include Filtering

    allowed_search_columns %w[platform_guid]
    allowed_sort_columns %w[platform_guid]

    # NOTE: This endpoint is deprecated & only used by the legacy admin panel
    def search
      page = AtomicTenant::PinnedPlatformGuid
        .where(application_instance_id: params[:application_instance_id])
        .order(:id).paginate(page: params[:page], per_page: 30)
      render json: {
        pinned_platform_guids: page,
        page: params[:page],
        total_pages: page.total_pages
      }
    end

    def index
      query = AtomicTenant::PinnedPlatformGuid.where(application_instance_id:)
      page, meta = filter(query)

      render json: {
        pinned_platform_guids: page,
        meta:
      }
    end

    def create
      result = AtomicTenant::PinnedPlatformGuid.create!({**pinned_platform_guid_params, application_instance_id:, application_id:})
      render json: { pinned_platform_guid: result }
    end

    def show
      pinned_platform_guid = find_pinned_platform_guid
      render json: {pinned_platform_guid: pinned_platform_guid}
    end

    def update
      pinned_platform_guid = find_pinned_platform_guid
      pinned_platform_guid.update!(pinned_platform_guid_params)

      render json: {pinned_platform_guid: find_pinned_platform_guid}
    end

    def destroy
      pinned_platform_guid = find_pinned_platform_guid
      pinned_platform_guid.destroy
      render json: { pinned_platform_guid: pinned_platform_guid }
    end

    private

    def application_id
      params[:application_id]
    end

    def application_instance_id
      params[:application_instance_id]
    end

    def pinned_platform_guid_params
      params.permit(:iss, :platform_guid, :application_id, :application_instance_id)
    end

    def find_pinned_platform_guid
      AtomicTenant::PinnedPlatformGuid.find(params[:id])
    end
  end
end
