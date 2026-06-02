# Overriding Controllers

The controllers that the gem provides are designed to be overridable.

To override the `ApplicationInstancesController` you create a new controller at the correct path, and can inherit from the gem's controller. For example:

```ruby
# app/controllers/atomic_admin/api/admin/v1/application_instances_controller.rb

class AtomicAdmin::Api::Admin::V1::ApplicationInstancesController < AtomicAdmin::V1::ApplicationInstancesController
  # Override the index action
  def index
      # Custom logic here
      super # Call the original method if needed
  end

  # Add any other custom actions or overrides here
end
```

