module AtomicAdmin::Api::Admin::V0
  class AuthenticatingApplicationController < ActionController::API
    include AtomicAdmin::RequireJwtToken
    before_action :validate_internal_token
  end
end
