module AtomicAdmin
  class Engine < ::Rails::Engine
    isolate_namespace AtomicAdmin
    config.generators.api_only = true

    config.after_initialize do
      AtomicAdmin.verify_admin_jwks_file!
    end
  end
end
