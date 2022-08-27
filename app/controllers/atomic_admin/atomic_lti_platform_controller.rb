module AtomicAdmin
  class AtomicLtiPlatformController < ApplicationController
    def platform_params
      params.permit(:iss, :jwks_url, :token_url, :oidc_url)
    end

    def find_platform
      AtomicLti::Platform.find_by(id: params[:id])
    end

    def index
      page = AtomicLti::Platform.all.order(:id).paginate(page: params[:page], per_page: 30)
      render json: page
    end

    def create
      AtomicLti::Platform.create!(platform_params)
    end

    def show
      platform = find_platform
      render json: platform
    end

    def update
      platform = find_platform
      result = platform.update!(platform_params)
      render json: result
    end

    def destroy
      platform = find_platform
      platform.destroy
      render json: platform
    end
  end
end
