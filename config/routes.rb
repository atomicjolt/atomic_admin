AtomicAdmin::Engine.routes.draw do
  resources :atomic_lti_platform
  resources :atomic_lti_install
  resources :atomic_tenant_deployment
  post '/atomic_tenant_deployment/search', to: 'atomic_tenant_deployment#search'

  resources :atomic_tenant_platform_guid_strategy
  post '/atomic_tenant_platform_guid_strategy/search', to: 'atomic_tenant_platform_guid_strategy#search'
  post '/atomic_tenant_client_id_strategy/search', to: 'atomic_tenant_client_id_strategy#search'

  resources :atomic_tenant_client_id_strategy

  resources :atomic_sites

  resources :atomic_applications do
    member do
      get :interactions
    end

    resources :atomic_application_instances do
      member do
        get :interactions
      end

      resources :atomic_client_id_strategies, controller: 'atomic_tenant_client_id_strategy'
      resources :atomic_platform_guid_strategies, controller: 'atomic_tenant_platform_guid_strategy'
      resources :atomic_deployments, controller: 'atomic_tenant_deployment'
    end
  end
end
