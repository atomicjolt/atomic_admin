module AtomicAdmin::V1
  class LtiPlatformsController < AdminController
    include Filtering

    allowed_search_columns %w[iss]
    allowed_sort_columns %w[iss]

    def index
      platforms, meta = filter(AtomicLti::Platform.all)

      render json: { platforms:, meta: }
    end

    def create
      platform = AtomicLti::Platform.create!(create_params)
      render json: { platform: platform }
    end

    def show
      platform = find_platform
      render json: platform
    end

    def update
      platform = find_platform
      platform.update!(update_params)
      render json: { platform: find_platform }
    end

    def destroy
      platform = find_platform
      platform.destroy
      render json: platform
    end

    protected

    def create_params
      params.require(:platform).permit!
    end

    def update_params
      params.require(:platform).permit!
    end

    def find_platform
      AtomicLti::Platform.find_by(id: params[:id])
    end
  end
end
