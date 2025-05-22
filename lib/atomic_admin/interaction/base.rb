module AtomicAdmin::Interaction
  class Base
    attr_accessor :key, :type, :key, :title, :icon, :order

    def initialize(key:, type:, title: nil, icon: nil, order: 0, **kwargs)
      @key = key
      @title = title
      @icon = icon
      @order = order
      @data = kwargs
      @type = type
    end

    def resolve(**kwargs)
      {
        key: key,
        type: type,
        title: title,
        icon: icon,
      }
    end


    def to_prepare
    end
  end
end
