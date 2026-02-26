module AtomicAdmin::V1
  class TenantClientIdStrategiesController < AdminController
    include AtomicAdmin::Filtering

    allowed_search_columns %w[client_id, iss]
    allowed_sort_columns %w[client_id, iss]

    before_action :check_restrictions, only: %i[create]

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
      result = AtomicTenant::PinnedClientId.create!({**create_params, application_instance_id:})
      render json: { pinned_client_id: result }
    end

    def destroy
      pinned_client_id = find_pinned_client_id
      pinned_client_id.destroy
      render json: { pinned_client_id: pinned_client_id }
    end

    protected

    def application_instance_id
      params[:application_instance_id] || params[:application_instance_id]
    end

    def create_params
      params.require(:pinned_client_id).permit!
    end

    def find_pinned_client_id
      AtomicTenant::PinnedClientId.find_by(id: params[:id])
    end

    def check_restrictions
      return if interaction.nil?

      if interaction.data[:restricted_client_id_prefixes]
        prefixes = interaction.data[:restricted_client_id_prefixes]

        prefixes.each do |prefix|
          if create_params[:iss] == prefix[:iss] && create_params[:client_id].start_with?(prefix[:prefix])
            render json: { error: prefix[:reason] }, status: :forbidden
            return
          end
        end
      end

      if interaction.data[:restricted_client_id_issuers]
        issuers = interaction.data[:restricted_client_id_issuers]
        if issuers.any? { |issuer| create_params[:iss] == issuer }
          render json: { error: "This ISS is blocked from client_id pinning. Pin by deployment instead." }, status: :forbidden
          return
        end
      end
    end

    def interaction
      @interaction ||= AtomicAdmin.application_instance_interactions.for_type(:lti_advantage).first
    end
  end
end
