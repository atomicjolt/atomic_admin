module AtomicAdmin
  class AtomicTenantDeploymentController < ApplicationController
    def deployment_params
      params.permit(:iss, :deployment_id, :application_instance_id)
    end

    def find_deployment
      AtomicTenant::LtiDeployment.find_by(id: params[:id])
    end

    def search
       tenant_deployments = AtomicTenant::LtiDeployment
        .where(application_instance_id: params[:application_instance_id])
        .order(:id)
        .paginate(page: params[:page], per_page: 30)

      page_ids = tenant_deployments.pluck(:id)

      page = AtomicLti::Deployment.where(id: page_ids)

      render json: {
        deployments: page,
        page: params[:page],
        total_pages: tenant_deployments.total_pages
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
