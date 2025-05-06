module AtomicAdmin::V1
  class SitesController < AdminController
    include Filtering

    allowed_search_columns %w[url]
    allowed_sort_columns %w[url]

    def index
      @sites = Site.all
      sites, meta = filter(@sites)
      render json: { sites: json_for_collection(sites), meta: }
    end

    def create
      @site = Site.create!(create_params)
      render json: { site: json_for(@site) }
    end

    def update
      @site = Site.find(params[:id])
      @site.update!(update_params)
      render json: { site: json_for(@site) }
    end

    def destroy
      @site = Site.find(params[:id])
      @site.destroy!
      render json: { site: json_for(@site) }
    end

    private

    def json_for(site)
      site.as_json
    end

    def create_params
      params.permit(:url, :oauth_key, :oauth_secret)
    end

    def update_params
      params.permit(:url, :oauth_key, :oauth_secret)
    end
  end
end
