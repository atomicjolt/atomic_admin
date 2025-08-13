module AtomicAdmin
  class AtomicTenantDeploymentController < ApplicationController
    def deployment_params
      params.permit(:iss, :deployment_id, :application_instance_id)
    end

    def find_deployment
      AtomicTenant::LtiDeployment.find_by(id: params[:id])
    end

    def search
      tenant_deployments = AtomicTenant::LtiDeployment.
        where(application_instance_id: params[:application_instance_id]).
        joins("LEFT OUTER JOIN public.atomic_lti_deployments"\
          " ON atomic_tenant_lti_deployments.iss = atomic_lti_deployments.iss"\
          " AND atomic_tenant_lti_deployments.deployment_id = atomic_lti_deployments.deployment_id").
        order(:id).
        paginate(page: params[:page], per_page: params[:per_page] || 30)

      rows = tenant_deployments.pluck(
        "atomic_tenant_lti_deployments.id",
        "atomic_tenant_lti_deployments.iss",
        "atomic_tenant_lti_deployments.deployment_id",
        "atomic_tenant_lti_deployments.application_instance_id",
        "atomic_lti_deployments.client_id",
        "atomic_lti_deployments.platform_guid",
      )

      page = rows.map do |row|
        {
          id: row[0],
          iss: row[1],
          deployment_id: row[2],
          application_instance_id: row[3],
          client_id: row[4],
          platform_guid: row[5],
        }
      end

      render json: {
        deployments: page,
        page: params[:page],
        total_pages: tenant_deployments.total_pages,
      }
    end

    # def index
    #   page = AtomicTenant::LtiDeployment.all.order(:id).paginate(page: params[:page], per_page: 30)
    #   render json: {
    #     deployments: page,
    #     page: params[:page],
    #     total_pages: page.total_pages
    #   }
    # end

    def create
      result = AtomicTenant::LtiDeployment.create!(deployment_params)
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
  end
end
