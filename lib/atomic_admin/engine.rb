module AtomicAdmin
  class Engine < ::Rails::Engine
    isolate_namespace AtomicAdmin
    config.generators.api_only = true
  end
end
