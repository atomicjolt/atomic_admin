AtomicAdmin::Engine.routes.draw do
    # namespace :lti do 
  resources :atomic_lti_platform
  resources :atomic_lti_install
  resources :atomic_tenant_deployment
  post '/atomic_tenant_deployment/search', to: 'atomic_tenant_deployment#search'

  resources :atomic_tenant_platform_guid_strategy
  post '/atomic_tenant_platform_guid_strategy/search', to: 'atomic_tenant_platform_guid_strategy#search'
  post '/atomic_tenant_client_id_strategy/search', to: 'atomic_tenant_client_id_strategy#search'

  resources :atomic_tenant_client_id_strategy
end
