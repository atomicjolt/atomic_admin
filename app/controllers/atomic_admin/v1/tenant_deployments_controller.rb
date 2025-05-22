module AtomicAdmin::V1
  class TenantDeploymentsController < AdminController
    include AtomicAdmin::Filtering

    allowed_search_columns %w[deployment_id, iss]
    allowed_sort_columns %w[deployment_id, iss]

    def index
      page, meta = filter(AtomicTenant::LtiDeployment.where(application_instance_id:))

      render json: {
        deployments: page,
        meta:
      }
    end

    def create
      result = AtomicTenant::LtiDeployment.create!({**create_params, application_instance_id:})
      render json: { deployment: result }
    end

    def show
      deployment = find_deployment
      render json: { deployment: deployment }
    end

    def destroy
      deployment = find_deployment
      deployment.destroy
      render json: { deployment: deployment }
    end

    protected

    def application_instance_id
      params[:application_instance_id]
    end

    def create_params
      params.require(:deployment).permit!
    end

    def find_deployment
      AtomicTenant::LtiDeployment.find_by(id: params[:id])
    end
  end
end
