module AtomicAdmin
  class AtomicTenantClientIdStrategyController < ApplicationController
    def pinned_client_id_params
      params.permit(:iss, :client_id, :application_instance_id)
    end

    def find_pinned_client_id
      AtomicTenant::PinnedClientId.find_by(id: params[:id])
    end

    def index 
      page = AtomicTenant::PinnedClientId.all.all.order(:id).paginate(page: params[:page], per_page: 30)
      render json: page
    end

    def create
      AtomicLti::Platform.create!(pinned_client_id_params)
    end

    def show
      platform = find_pinned_client_id
      render json: platform
    end
    
    # def update
    #   platform = find_pinned_client_id
    #   result = platform.update!(pinned_client_id_params)
    #   render json: result
    # end

    def destroy
      platform = find_pinned_client_id
      platform.destroy
      render json: platform
    end
  end
end
