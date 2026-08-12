module AtomicAdmin::Interaction
  class Base
    attr_accessor :key, :type, :key, :title, :icon, :order, :data, :permissions

    def initialize(key:, type:, title: nil, icon: nil, order: 0, permissions: [], **kwargs)
      @key = key
      @type = type
      @title = title
      @icon = icon
      @order = order
      @permissions = permissions
      @data = kwargs
    end

    def resolve(**kwargs)
      {
        key: key,
        type: type,
        title: title,
        icon: icon,
        permissions: permissions,
      }
    end
  end
end
