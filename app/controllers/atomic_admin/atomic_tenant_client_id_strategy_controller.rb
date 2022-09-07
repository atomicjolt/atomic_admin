module AtomicAdmin
  class AtomicTenantClientIdStrategyController < ApplicationController
    def pinned_client_id_params
      params.permit(:iss, :client_id, :application_instance_id)
    end

    def find_pinned_client_id
      AtomicTenant::PinnedClientId.find_by(id: params[:id])
    end

    def search 
      page = AtomicTenant::PinnedClientId
        .where(application_instance_id: params[:application_instance_id])
        .order(:id).paginate(page: params[:page], per_page: 30)
      render json: {
        pinned_client_ids: page,
        page: params[:page],
        total_pages: page.total_pages
      }
    end

    # def index
    #   page = AtomicTenant::PinnedClientId.all.order(:id).paginate(page: params[:page], per_page: 30)
    #   render json: {
    #     pinned_client_ids: page,
    #     page: params[:page],
    #     total_pages: page.total_pages
    #   }
    # end

    def create
      result = AtomicTenant::PinnedClientId.create!(pinned_client_id_params)
      render json: { pinned_client_id: result }
    end

    def show
      pinned_client_id = find_pinned_client_id
      render json: {pinned_client_id: pinned_client_id}
    end

    def update
      pinned_client_id = find_pinned_client_id
      pinned_client_id.update!(pinned_client_id_params)

      render json: {pinned_client_id: find_pinned_client_id}
    end

    def destroy
      pinned_client_id = find_pinned_client_id
      pinned_client_id.destroy
      render json: { pinned_client_id: pinned_client_id }
    end
  end
end
