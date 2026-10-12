module AtomicAdmin::V1
  # The API behind Skipper's `capabilities` interaction: a matrix of
  # capabilities by roles, where each cell is what the role grants by default
  # or an override row (ALLOW, DENY or PROHIBIT) at one scope. A scope is
  # everywhere ("global"), one account ("account:<account id>") or one course
  # ("course:<context id>").
  #
  # Rows are read and written through the host app's RoleCapability model
  # (role, capability, mode, context_id, account_id) and Role model (name). The
  # catalog, role defaults and account and course names come from the
  # interaction's provider, an AtomicAdmin::RoleCapabilities::Provider
  # subclass. See docs/interactions.md.
  class RoleCapabilitiesController < AdminController
    GLOBAL_SCOPE = "global".freeze
    MODES = %w[ALLOW DENY PROHIBIT].freeze

    around_action :switch_tenants

    # The catalog, every role with what it grants by default, every override
    # row for the catalog's capabilities, and the accounts and courses those
    # rows are scoped to.
    def show
      rows = catalog_rows(RoleCapability.includes(:role).to_a)

      render json: {
        groups: provider.capability_groups,
        capabilities: provider.capability_catalog,
        modes: MODES,
        tiers: provider.role_tiers,
        roles: provider.listed_roles.map { |role| role_json(role) },
        custom_roles: provider.custom_roles,
        rows: rows.map { |row| row_json(row) },
        scopes: scopes_json_for(rows),
        notes: provider.notes,
      }
    end

    # Replaces one role's override rows at one scope. A missing overrides key
    # clears them.
    #
    #   PATCH { role: { name: "canvas:Grade Viewer" }, scope: "account:12",
    #           overrides: { "reply_create" => "PROHIBIT", ... } }
    def update
      name = role_name_param
      return render_unprocessable("role.name is required") if name.blank?

      scope_key = params[:scope].presence || GLOBAL_SCOPE
      context_id, account_id = parse_scope(scope_key)
      if context_id.nil? && account_id.nil? && scope_key != GLOBAL_SCOPE
        return render_unprocessable("scope must be global, account:<account id> or course:<context id>")
      end
      if context_id && provider.course_scopes([context_id]).empty?
        return render_unprocessable("No course with context id #{context_id} has launched this tool")
      end

      overrides = params.key?(:overrides) ? overrides_param : {}
      return render_unprocessable("overrides must map capability names to modes") if overrides.nil?

      overrides = overrides.compact_blank
      unknown = overrides.keys - provider.capability_names
      return render_unprocessable("Unknown capabilities: #{unknown.join(', ')}") if unknown.any?

      invalid_modes = overrides.values.uniq - MODES
      return render_unprocessable("Unknown modes: #{invalid_modes.join(', ')}") if invalid_modes.any?

      role = provider.role_for_update(name)
      return render_unprocessable("Unknown role: #{name}") if role.nil?

      provider.replace_overrides!(role, overrides, context_id:, account_id:)
      saved = catalog_rows(RoleCapability.where(role:, context_id:, account_id:).includes(:role).to_a)

      render json: {
        role: role_json(role),
        scope: scope_key,
        overrides: saved.to_h { |row| [row.capability, row.mode] },
      }
    rescue ActiveRecord::RecordInvalid => e
      render_unprocessable(e.record.errors.full_messages.join(", "))
    end

    # Accounts and courses matching a search, for the scope picker.
    #
    #   GET ?q=law
    def scopes
      render json: { scopes: provider.search_scopes(params[:q].to_s.strip) }
    end

    private

    def application_instance
      @application_instance ||= ApplicationInstance.find(params[:application_instance_id])
    end

    def provider
      @provider ||= interaction.provider_class.new(application_instance:)
    end

    # The routes are only drawn when a capabilities interaction is registered.
    def interaction
      AtomicAdmin.application_instance_interactions.for_type(:capabilities).first
    end

    def switch_tenants(&)
      Apartment::Tenant.switch(application_instance.tenant, &)
    end

    def render_unprocessable(message)
      render json: { error: message }, status: 422
    end

    # Only rows for the catalog's capabilities. Other rows stay stored but are
    # not this editor's to show or save back.
    def catalog_rows(rows)
      rows.select { |row| provider.capability_names.include?(row.capability.to_s) }
    end

    def role_json(role)
      tier = provider.role_tier(role)&.to_s
      {
        id: role.id,
        name: role.name,
        display_name: provider.role_display_name(role),
        kind: provider.role_kind(role),
        custom: provider.custom_role?(role),
        tier:,
        tier_label: provider.role_tiers.find { |t| t[:key].to_s == tier }&.dig(:label),
        defaults: (provider.role_defaults(role).map(&:to_s) & provider.capability_names).sort,
      }
    end

    def row_json(row)
      { role: row.role.name, scope: scope_key_for(row), capability: row.capability.to_s, mode: row.mode }
    end

    def scope_key_for(row)
      if row.context_id
        "course:#{row.context_id}"
      elsif row.account_id
        "account:#{row.account_id}"
      else
        GLOBAL_SCOPE
      end
    end

    # [context_id, account_id] for a scope key; [nil, nil] for global and for
    # anything malformed (the caller tells the two apart). Context ids are
    # opaque, so only the first ":" separates the type.
    def parse_scope(key)
      type, id = key.to_s.split(":", 2)
      return [nil, nil] if id.blank?

      case type
      when "course" then [id, nil]
      when "account" then provider.valid_account_id?(id) ? [nil, id] : [nil, nil]
      else [nil, nil]
      end
    end

    # Names for the scopes the rows use. A course that is gone keeps its rows
    # listed under an unnamed scope.
    def scopes_json_for(rows)
      account_ids = rows.filter_map(&:account_id).uniq
      context_ids = rows.filter_map(&:context_id).uniq
      courses = provider.course_scopes(context_ids).index_by { |scope| scope[:id] }

      provider.account_scopes(account_ids) +
        context_ids.map { |id| courses[id] || provider.course_scope_json(id) }
    end

    # `role` must be an object with a name; anything else is treated as missing.
    def role_name_param
      role = params[:role]
      role.respond_to?(:key?) ? role[:name].to_s.strip : ""
    end

    # { capability => mode } with string or nil values, or nil when the shape
    # is wrong.
    def overrides_param
      overrides = params[:overrides]
      return nil unless overrides.respond_to?(:to_unsafe_h)

      overrides = overrides.to_unsafe_h
      return nil unless overrides.values.all? { |mode| mode.nil? || mode.is_a?(String) }

      overrides
    end
  end
end
