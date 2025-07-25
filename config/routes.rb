AtomicAdmin::Engine.routes.draw do
  namespace :api do
    namespace :admin do
      # NOTE: these are the "legacy" routes that the old admin app relies on. They don't follow the same conventions as the new API.
      # They are also not namespaces under /api/admin/v0 but rather /api/admin/*
      scope module: "v0" do
        resources :atomic_lti_platform
        resources :atomic_lti_install
        resources :atomic_tenant_deployment
        post '/atomic_tenant_deployment/search', to: 'atomic_tenant_deployment#search'

        resources :atomic_tenant_platform_guid_strategy
        post '/atomic_tenant_platform_guid_strategy/search', to: 'atomic_tenant_platform_guid_strategy#search'

        resources :atomic_tenant_client_id_strategy
        post '/atomic_tenant_client_id_strategy/search', to: 'atomic_tenant_client_id_strategy#search'
      end

      namespace :v1 do
        resources :lti_platforms
        resources :lti_installs
        resources :tenant_deployments
        resources :sites

        resources :applications do
          member do
            get :interactions
          end

          resources :application_instances do
            member do
              get :interactions
            end

            resources :tenant_client_id_strategies
            resources :tenant_platform_guid_strategies
            resources :tenant_deployments
            resources :stats

            AtomicAdmin.application_instance_interactions.for_type(:resource).each do |interaction|
              controller_name = interaction.key.to_s.pluralize
              resources controller_name do
                collection do
                  get :interactions
                end
              end
            end
          end
        end
      end
    end
  end
end
