module AtomicAdmin
  module RoleCapabilities
    # What a host app supplies for the `capabilities` interaction: the
    # capability catalog, what each role grants by default, and how accounts
    # and courses are named and found. Subclass it, implement
    # `capability_catalog` and `role_defaults`, override any other hook, and
    # name the class in the interaction's `provider:` option.
    #
    # AtomicAdmin::V1::RoleCapabilitiesController builds one per request with
    # the application instance, inside that instance's tenant, and reads and
    # writes the host's RoleCapability rows (role, capability, mode,
    # context_id, account_id) itself.
    class Provider
      attr_reader :application_instance

      def initialize(application_instance:)
        @application_instance = application_instance
      end

      # Required. The capabilities this application instance can grant, in
      # display order: [{ name:, group:, label:, description: }].
      def capability_catalog
        raise NotImplementedError, "#{self.class.name} must implement capability_catalog"
      end

      # Required. The capability names one role grants when it has no override
      # rows.
      def role_defaults(_role)
        raise NotImplementedError, "#{self.class.name} must implement role_defaults"
      end

      # The catalog's groups in order: [{ key:, label: }].
      def capability_groups
        capability_catalog.map { |capability| capability[:group].to_s }.uniq.map do |group|
          { key: group, label: group.humanize }
        end
      end

      # The default sets roles fall into, highest first: [{ key:, label: }].
      # Columns are ordered by tier.
      def role_tiers
        []
      end

      # The key of the role's tier, or nil for a role that grants nothing by
      # default.
      def role_tier(_role)
        nil
      end

      # Every role that gets a column.
      def listed_roles
        Role.order(:name).to_a
      end

      # The column title for a role whose name is not a standard LTI role URI
      # (Skipper shortens those itself).
      def role_display_name(role)
        role.name
      end

      # What kind of role it is ("Canvas custom role"), or nil to let Skipper
      # work it out from an LTI role URI.
      def role_kind(_role)
        nil
      end

      # Whether the role is an LMS custom role added by name.
      def custom_role?(_role)
        false
      end

      # nil, or how roles that have not launched yet can be added by name:
      # { label: "Canvas custom role", prefix: "canvas:", example: "Grade Viewer" }.
      # Skipper stores a typed name as prefix + name.
      def custom_roles
        nil
      end

      # The role an update names, or nil to refuse it.
      def role_for_update(name)
        Role.find_by(name:)
      end

      # Whether an id from an "account:<id>" scope key can be an account id.
      def valid_account_id?(account_id)
        account_id.present?
      end

      # Scope entries for these account ids, in the same order. Build them
      # with account_scope_json.
      def account_scopes(account_ids)
        account_ids.map { |id| account_scope_json(id) }
      end

      # Scope entries for the courses among these context ids that have
      # launched the tool; leave the rest out. Build them with
      # course_scope_json. Course scopes cannot be saved until this is
      # implemented.
      def course_scopes(_context_ids)
        []
      end

      # Accounts and courses matching a search term.
      def search_scopes(_term)
        []
      end

      # Short notes shown under the matrix, such as how defaults combine.
      def notes
        []
      end

      # Replaces the role's rows for the catalog's capabilities at one scope.
      # Rows for capabilities outside the catalog are left alone.
      def replace_overrides!(role, overrides, context_id:, account_id:)
        RoleCapability.transaction do
          RoleCapability.where(role:, capability: capability_names, context_id:, account_id:).delete_all
          overrides.each do |capability, mode|
            RoleCapability.create!(role:, capability:, mode:, context_id:, account_id:)
          end
        end
      end

      def capability_names
        @capability_names ||= capability_catalog.map { |capability| capability[:name].to_s }
      end

      # `path` names the account's ancestors and the account itself, root
      # first.
      def account_scope_json(account_id, label: nil, path: [])
        {
          key: "account:#{account_id}",
          type: "account",
          id: account_id.to_s,
          label: label.presence || "Account #{account_id}",
          path:,
        }
      end

      # `account` is the course's account scope, from account_scope_json, if
      # known.
      def course_scope_json(context_id, label: nil, account: nil)
        {
          key: "course:#{context_id}",
          type: "course",
          id: context_id.to_s,
          label: label.presence || "Course #{context_id}",
          account:,
        }
      end
    end
  end
end
