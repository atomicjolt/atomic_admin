module AtomicAdmin::Api::Admin::V0
  class AuthenticatingApplicationController < ActionController::API
    include RequireJwtToken
    before_action :validate_internal_token
  end
end
