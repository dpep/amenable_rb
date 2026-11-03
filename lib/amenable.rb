require 'amenable/version'

module Amenable
  extend self

  def call(fn, *args, **kwargs, &block)
    unless fn.is_a?(Method) || fn.is_a?(Proc)
      raise ArgumentError, "expecting type Method or Proc, found: #{fn.class}"
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

  refine Object do
    def amenable(name)
      defines = ->(owner) do
        owner.method_defined?(name, false) || owner.private_method_defined?(name, false)
      end

      wrap = ->(owner) do
        fn = owner.instance_method(name)
        visibility =
          if owner.private_method_defined?(name, false) then :private
          elsif owner.protected_method_defined?(name, false) then :protected
          else :public
          end

        owner.send(:define_method, name) do |*args, **kwargs, &block|
          # bind per call: `fn` is shared by every receiver, so never reassign it
          Amenable.call(fn.bind(self), *args, **kwargs, &block)
        end
        owner.send(visibility, name)
      end

      # in a class body, `def foo` means the instance method; only fall back
      # to the singleton side when there isn't one
      if is_a?(Module) && defines.call(self)
        # module_function leaves an identical copy on the singleton: wrap both
        copy = defines.call(singleton_class) &&
          singleton_class.instance_method(name).source_location == instance_method(name).source_location

        wrap.call(self)
        wrap.call(singleton_class) if copy
      elsif defines.call(singleton_class)
        wrap.call(singleton_class)
      else
        raise NoMethodError
      end

      name
    end
  end
end
