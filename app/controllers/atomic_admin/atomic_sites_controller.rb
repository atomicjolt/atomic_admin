module AtomicAdmin
  class AtomicSitesController < ApplicationController
    include Filtering

    def index
      @sites = Site.all
      render json: { sites: json_for_collection(filter(@sites, search_col: "url")) }
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
      site.as_json(include: :leads)
    end

    def create_params
      params.permit(:url, :oauth_key, :oauth_secret)
    end

    def update_params
      params.permit(:url, :oauth_key, :oauth_secret)
    end
  end
end
