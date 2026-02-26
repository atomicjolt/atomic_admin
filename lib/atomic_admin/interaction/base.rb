module AtomicAdmin::Interaction
  class Base
    attr_accessor :key, :type, :key, :title, :icon, :order, :data

    def initialize(key:, type:, title: nil, icon: nil, order: 0, **kwargs)
      @key = key
      @type = type
      @title = title
      @icon = icon
      @order = order
      @data = kwargs
    end

    def resolve(**kwargs)
      {
        key: key,
        type: type,
        title: title,
        icon: icon,
      }
    end
  end
end
