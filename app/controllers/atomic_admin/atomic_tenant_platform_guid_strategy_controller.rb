module AtomicAdmin
  class AtomicTenantPlatformGuidStrategyController < ApplicationController
    def pinned_platform_guid_params
      params.permit(:iss, :platform_guid, :application_id, :application_instance_id)
    end

    def find_pinned_platform_guid
      AtomicTenant::PinnedPlatformGuid.find(params[:id])
    end

    def index 
      page = AtomicTenant::PinnedPlatformGuid.all.order(:id).paginate(page: params[:page], per_page: 30)
      render json: {
        pinned_platform_guids: page,
        page: params[:page],
        total_pages: page.total_pages
      }
    end

    def create
      result = AtomicTenant::PinnedPlatformGuid.create!(pinned_platform_guid_params)
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
  end
end
