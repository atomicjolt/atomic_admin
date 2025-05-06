module AtomicAdmin::V1
  class TenantClientIdStrategiesController < AdminController
    include Filtering

    allowed_search_columns %w[client_id]
    allowed_sort_columns %w[client_id]

    def index
      query = AtomicTenant::PinnedClientId.where(application_instance_id:)
      page, meta = filter(query)

      render json: {
        pinned_client_ids: page,
        meta:
      }
    end

    def show
      pinned_client_id = find_pinned_client_id
      render json: {pinned_client_id: pinned_client_id}
    end

    def create
      result = AtomicTenant::PinnedClientId.create!({**pinned_client_id_params, application_instance_id:})
      render json: { pinned_client_id: result }
    end

    # def update
    #   pinned_client_id = find_pinned_client_id
    #   pinned_client_id.update!(pinned_client_id_params)

    #   render json: { pinned_client_id: find_pinned_client_id }
    # end

    def destroy
      pinned_client_id = find_pinned_client_id
      pinned_client_id.destroy
      render json: { pinned_client_id: pinned_client_id }
    end

    private

    def application_instance_id
      params[:application_instance_id] || params[:application_instance_id]
    end

    def pinned_client_id_params
      params.permit(:iss, :client_id, :application_instance_id)
    end

    def find_pinned_client_id
      AtomicTenant::PinnedClientId.find_by(id: params[:id])
    end
  end
end
