module AtomicAdmin
  class AtomicLtiPlatformController < ApplicationController
    include Filtering

    def index
      platforms, meta = filter(AtomicLti::Platform.all, search_col: "iss")

      render json: { platforms:, meta: }
    end

    def create
      platform = AtomicLti::Platform.create!(platform_params)
      render json: { platform: platform }
    end

    def show
      platform = find_platform
      render json: platform
    end

    def update
      platform = find_platform
      platform.update!(platform_params)
      render json: { platform: find_platform }
    end

    def destroy
      platform = find_platform
      platform.destroy
      render json: platform
    end

    private

    def platform_params
      params.permit(:iss, :jwks_url, :token_url, :oidc_url)
    end

    def find_platform
      AtomicLti::Platform.find_by(id: params[:id])
    end
  end
end
