module AtomicAdmin::V1
  class LtiInstallsController < AdminController
    def index
      render json: AtomicLti::Install.all.order(:id).paginate(page: params[:page], per_page: 30)
    end

    def create
      AtomicLti::Install.create!(create_params)
    end

    def show
      install = find_install
      render json: install
    end

    def update
      install = find_install
      result = install.update!(update_params)
      render json: result
    end

    def destroy
      install = find_install
      install.destroy
      render json: install
    end

    protected

    def find_install
      AtomicLti::Install.find_by(id: params[:id])
    end

    def create_params
      params.permit!
    end

    def update_params
      params.permit!
    end
  end
end
