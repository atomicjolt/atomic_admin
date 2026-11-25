# atomic_admin
Engine to provide apis that power the atomic jolt admin app

# Usage

Add the gem to your project:
gem 'atomic_admin',  git: 'https://github.com/atomicjolt/atomic_admin.git', tag: '0.1.0'

Add the following to routes.rb:
  ```
  namespace :api do
    namespace :admin do
      mount AtomicAdmin::Engine => "/"
    end
  end
  ```

## Admin JWKS

Requests from the admin app are signed with its key. Configure where the
public keys come from in an initializer:

  ```ruby
  AtomicAdmin.configure do |config|
    # Read the JWKS from this file in the config directory. config/k8s/ is
    # checked first (where External Secrets mounts it when deployed), then
    # config/, the same as ConfigLoader. It is read on every request, so
    # rotated keys are picked up without a restart. If it's set and neither
    # file exists, the app fails to start with
    # AtomicAdmin::JwtToken::MissingJwksError (except during assets:*
    # tasks, e.g. precompiling in a Docker build). Locally, save your admin
    # app's /jwks.json as config/admin-jwks.json.
    config.admin_jwks_file = "admin-jwks.json"

    # Or, without admin_jwks_file, fetch it from the admin app. Cached until a
    # token arrives with an unknown kid.
    # config.admin_jwks_url = "https://admin.example.com/jwks.json"
  end
  ```
