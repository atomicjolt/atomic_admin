AtomicAdmin::Engine.routes.draw do
    # namespace :lti do 
  resources :atomic_lti_platform
  resources :atomic_lti_install
  resources :atomic_lti_deployment
  resources :atomic_tenant_platform_guid_strategy
  post '/atomic_tenant_platform_guid_strategy/search', to: 'atomic_tenant_platform_guid_strategy#search'

  resources :atomic_tenant_platform_client_id_strategy
end
