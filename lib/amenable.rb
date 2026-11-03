require 'amenable/version'

module Amenable
  extend self

  def call(fn, *args, **kwargs, &block)
    unless fn.is_a?(Method) || fn.is_a?(Proc)
      raise ArgumentError, "expecting type Method or Proc, found: #{fn.class}"
    end

    rest = keyrest = false
    # a non-lambda proc drops extra positionals itself, and trimming them can
    # make it auto-splat a lone Array
    loose = fn.is_a?(Proc) && !fn.lambda?
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
    args = args.slice(0, params.count) unless rest || loose

    if !keys.empty? || keyrest
      # remove excessive keywords
      kwargs = kwargs.slice(*keys) unless keyrest
    elsif !(rest || loose || args.size < params.count)
      # no keyword params: Ruby binds keywords to *rest or an open positional
      # slot as a Hash, so strip them only when there's nowhere for them to go
      kwargs = {}
    end

    # `**{}` is not a no-op: it stops a non-lambda proc auto-splatting
    kwargs.empty? ? fn.call(*args, &block) : fn.call(*args, **kwargs, &block)
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

      # a top-level `def` lands on Object, not on main's singleton class
      mod = TOPLEVEL_BINDING.receiver.equal?(self) ? Object : self

      # in a class body, `def foo` means the instance method; only fall back
      # to the singleton side when there isn't one
      if mod.is_a?(Module) && defines.call(mod)
        # module_function leaves an identical copy on the singleton: wrap both
        copy = defines.call(mod.singleton_class) &&
          mod.singleton_class.instance_method(name).source_location == mod.instance_method(name).source_location

        wrap.call(mod)
        wrap.call(mod.singleton_class) if copy
      elsif defines.call(singleton_class)
        wrap.call(singleton_class)
      else
        raise NoMethodError.new(
          "amenable: no method '#{name}' defined directly on #{inspect}",
          name,
          receiver: self,
        )
      end

      name
    end
  end
end
