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
    # Read the JWKS from a file, e.g. one mounted by External Secrets from
    # Parameter Store. Used whenever the file exists. It is read on every
    # request, so rotated keys are picked up without a restart.
    config.admin_jwks_path = "/app/config/k8s/admin-jwks.json"

    # Otherwise fetch it from the admin app. Cached until a token arrives
    # with an unknown kid.
    config.admin_jwks_url = "https://admin.example.com/jwks.json"
  end
  ```
