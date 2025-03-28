require "rails/generators"

module AtomicAdmin
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    class_option :version, type: :string, default: 'v1', desc: 'API version (e.g. v1, v2). Defaults to v1'

    def validate_version
      unless options[:version].match?(/^v\d+$/)
        raise ArgumentError, 'Version must be in the format "v1", "v2", etc.'
      end
    end

    def create_admin_api_controllers
      @version =  options[:version]

      controllers = [
        'applications',
        'application_instances',
        'lti_platforms',
        'lti_installs',
        'tenant_deployments',
        'tenant_platform_guid_strategies',
        'tenant_client_id_strategies',
        'sites'
      ]

      controllers.each do |controller|
        @controller = controller
        template(
          'controller.rb.erb',
          "app/controllers/api/admin/#{options[:version]}/#{controller}_controller.rb",
        )
      end
    end
  end
end
