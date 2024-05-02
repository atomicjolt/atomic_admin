class AtomicAdmin::Interaction::BaseInteraction
  def initialize(**kwargs)
    kwargs.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def self.inherited(base)
    AtomicAdmin::Interaction::Manager.register(base)
    base.class_variable_set(:@@enabled, true)
  end

  def self.group(group)
    class_variable_set(:@@group, group)
  end

  def self.type(type)
    class_variable_set(:@@type, type)
  end

  def self.title(title)
    class_variable_set(:@@title, title)
  end

  def self.icon(icon)
    class_variable_set(:@@icon, icon)
  end

  def self.key(key)
    class_variable_set(:@@key, key)
  end

  def self.order(order)
    class_variable_set(:@@order, order)
  end

  def self.disable!
    class_variable_set(:@@enabled, false)
  end

  def self.enable!
    class_variable_set(:@@enabled, true)
  end
end
