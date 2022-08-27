module AtomicAdmin
  class AtomicLtiInstallController < ApplicationController
    def install_params
      params.permit(:iss, :client_id)
    end

    def find_install
      AtomicLti::Install.find_by(id: params[:id])
    end

    def index
      render json: AtomicLti::Install.all
    end

    def create
      AtomicLti::Install.create!(install_params)
    end

    def show
      install = find_install
      render json: install
    end

    def update
      install = find_install
      result = install.update!(install_params)
      render json: result
    end

    def destroy
      install = find_install
      install.destroy
      render json: install
    end
  end
end
