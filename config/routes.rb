AtomicAdmin::Engine.routes.draw do
    # namespace :lti do 
  resources :atomic_lti_platform
  resources :atomic_lti_install
  resources :atomic_lti_deployment
    # end
    # TODO 
    # strategies
end
