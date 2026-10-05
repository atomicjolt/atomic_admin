module AtomicAdmin::Interaction
  # Skipper's Role Capabilities editor. `provider` is an
  # AtomicAdmin::RoleCapabilities::Provider subclass, or its name; it is
  # looked up on each request so it reloads in development.
  class Capabilities < AtomicAdmin::Interaction::Base
    def initialize(provider:, **kwargs)
      super(**kwargs)
      @provider = provider
    end

    def provider_class
      @provider.is_a?(String) ? @provider.constantize : @provider
    end
  end
end
