AtomicAdmin::Engine.routes.draw do
  namespace :api do
    namespace :admin do
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
              get :stats
            end

            resources :tenant_client_id_strategies
            resources :tenant_platform_guid_strategies
            resources :tenant_deployments
            resources :analytics
          end
        end
      end
    end
  end
end
