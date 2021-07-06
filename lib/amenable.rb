require 'amenable/version'

module Amenable
  extend self

  def call(fn, *args, **kwargs, &block)
    wrap(fn).call(*args, **kwargs, &block)
  end

  def wrap(fn)
    unless fn.respond_to?(:call)
      raise ArgumentError, "fn must be callable: #{fn}"
    end

    rest = keyrest = false
    params = []
    keys = []

    fn.parameters.each do |type, name|
      case type
      when :req, :opt
        params << name
      when :key, :keyreq
        keys << name
      when :rest
        rest = true
      when :keyrest
        keyrest = true
      end
    end

    proc do |*args, **kwargs, &block|
      # remove excessive args
      args = args.slice(0, params.count) unless rest

      if !keys.empty? || keyrest
        # remove excessive keywords
        kwargs = kwargs.slice(*keys) unless keyrest
        fn.call(*args, **kwargs, &block)
      else
        fn.call(*args, &block)
      end
    end
  end

  refine Object do
    def amenable(name)
      # identify method and way to dynamically redefine it
      if methods(false).include?(name)
        fn = method(name).unbind # rebind later to support subclassing
        definer = method(:define_singleton_method)
      elsif private_methods(false).include?(name)
        fn = method(name).unbind
        definer = ->(name, &block) do
          define_singleton_method(name, &block)
          private_class_method(name)
        end
      elsif private_instance_methods(false).include?(name)
        fn = instance_method(name)
        definer = ->(name, &block) do
          define_method(name, &block)
          private(name)
        end
      elsif protected_instance_methods(false).include?(name)
        fn = instance_method(name)
        definer = ->(name, &block) do
          define_method(name, &block)
          protected(name)
        end
      elsif instance_methods(false).include?(name)
        fn = instance_method(name)
        definer = method(:define_method)
      else
        raise NoMethodError
      end

      # rebuild method with Amenable wrapper
      definer.call(name) do |*args, &block|
        # bind method to instance or subclass, which is now available
        if fn.respond_to? :bind
          fn = fn.bind(self)
        end

        Amenable.call(fn, *args, &block)
      end

      name
    end
  end
end
