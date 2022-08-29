AtomicAdmin::Engine.routes.draw do
    # namespace :lti do 
  resources :atomic_lti_platform
  resources :atomic_lti_install
  resources :atomic_lti_deployment
  resources :atomic_tenant_platform_guid_strategy
  resources :atomic_tenant_platform_client_id_strategy
    # end
    # TODO 
    # strategies
end
