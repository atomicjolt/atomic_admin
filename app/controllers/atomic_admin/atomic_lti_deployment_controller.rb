module AtomicAdmin
  class AtomicLtiDeploymentController < ApplicationController
    def deployment_params
      params.permit(:iss, :client_id)
    end

    def find_deployment
      AtomicLti::Deployment.find_by(id: params[:id])
    end

    def index
      render json: AtomicLti::Deployment.all.order(:id).paginate(page: params[:page], per_page: 30)
    end

    def create
      AtomicLti::Deployment.create!(deployment_params)
    end

    def show
      deployment = find_deployment
      render json: deployment
    end

    # def update
    #   deployment = find_deployment
    #   result = deployment.update!(deployment_params)
    #   render json: result
    # end

    def destroy
      deployment = find_deployment
      deployment.destroy
      render json: deployment
    end

  end
end
