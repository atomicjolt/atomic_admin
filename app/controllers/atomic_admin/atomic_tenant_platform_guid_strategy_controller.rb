module AtomicAdmin
  class AtomicTenantPlatformGuidStrategyController < ApplicationController
    def pinned_platform_guid_params
      params.permit(:iss, :platform_guid, :application_id, :application_instance_id)
    end

    def find_pinned_platform_guid
      AtomicTenant::PinnedPlatformGuid.find_by(id: params[:id])
    end

    def index 
      page = AtomicTenant::PinnedPlatformGuid.all.all.order(:id).paginate(page: params[:page], per_page: 30)
      render json: page
    end

    def create
      AtomicLti::Platform.create!(pinned_platform_guid_params)
    end

    def show
      platform = find_pinned_platform_guid
      render json: platform
    end
    
    # def update
    #   platform = find_pinned_platform_guid
    #   result = platform.update!(pinned_platform_guid_params)
    #   render json: result
    # end

    def destroy
      platform = find_pinned_platform_guid
      platform.destroy
      render json: platform
    end
  end
end
