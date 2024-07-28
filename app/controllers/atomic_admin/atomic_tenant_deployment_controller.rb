module AtomicAdmin
  class AtomicTenantDeploymentController < ApplicationController
    include Filtering

    def search
       tenant_deployments = AtomicTenant::LtiDeployment
        .where(application_instance_id: params[:application_instance_id])
        .order(:id)
        .paginate(page: params[:page], per_page: 30)

      page_ids = tenant_deployments.pluck(:iss, :deployment_id)

      pairs = page_ids.reduce({}) do |acc, c|
        iss = c[0]
        deployment_id = c[1]

        acc[iss] = [] if acc[iss].nil?

        acc[iss].push(deployment_id)
        acc
      end

      page = pairs.reduce([]) do |acc, pair|
        iss = pair[0]
        deployment_ids = pair[1]

        deployments = AtomicLti.get_deployments(iss: iss, deployment_ids: deployment_ids)
        acc.concat(deployments)
      end

      render json: {
        deployments: page,
        page: params[:page],
        total_pages: tenant_deployments.total_pages
      }
    end

    def index
      page, meta = filter(
        AtomicTenant::LtiDeployment.where(application_instance_id:),
        search_col: "deployment_id",
      )

      render json: {
        deployments: page,
        meta:
      }
    end

    def create
      result = AtomicTenant::LtiDeployment.create!({**deployment_params, application_instance_id:})
      render json: { deployment: result }
    end

    def show
      deployment = find_deployment
      render json: { deployment: deployment }
    end

    # def update
    #   deployment = find_deployment
    #   deployment.update!(deployment_params)

    #   render json: {deployment: find_deployment}
    # end

    def destroy
      deployment = find_deployment
      deployment.destroy
      render json: { deployment: deployment }
    end

    private

    def application_instance_id
      params[:application_instance_id] || params[:atomic_application_instance_id]
    end

    def deployment_params
      params.permit(:iss, :deployment_id, :application_instance_id)
    end

    def find_deployment
      AtomicTenant::LtiDeployment.find_by(id: params[:id])
    end
  end
end
