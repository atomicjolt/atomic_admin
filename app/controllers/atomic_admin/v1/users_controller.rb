module AtomicAdmin::V1
  class UsersController < AdminController
    include AtomicAdmin::Filtering

    around_action :switch_tenants

    allowed_sort_columns %w[name lti_user_id lms_user_id create_method]
    allowed_search_columns %w[name lti_user_id lms_user_id]

    def index
      query = User.includes(:roles).where.not(lti_user_id: nil)

      users, meta = filter(query)

      render json: { users: json_for(users), meta: meta }
    end

    def show
      @user = User.find(params[:id])
      render json: { user: json_for(@user) }
    end

    def update
      @user = User.find(params[:id])

      do_update(@user, params)

      render json: { user: json_for(@user) }
    end

    def bulk_update
      params[:users].each do |user_params|
        user = User.find(user_params[:id])
        do_update(user, user_params)
      end

      render json: { success: true }
    end

    def do_update(user, params)
      raise "Not implemented. This method should be implemented in a subclass of UsersController."
    end

    def json_for(relation)
      relation.as_json(
        include: :roles,
        only: [:id, :name, :lti_user_id, :lms_user_id]
      )
    end

    def switch_tenants(&)
      application_instance = ApplicationInstance.find(
        params[:application_instance_id]
      )

      Apartment::Tenant.switch(application_instance.tenant, &)
    end
  end
end
