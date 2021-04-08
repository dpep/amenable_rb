require 'amenable/version'

module Amenable
  def tighten(fn)
    name, redefiner = parse(fn)
    rebuild(fn, :tighten)

    # remount
  end

  private

  def parse fn
    case fn
    when Symbol
      name = fn
      fn = method(fn)
      redefiner = method(:define_method)
    when Method
      name = fn.name
      redefiner = method(:define_method)
    end

    [ name, redefiner ]
  end

  def rebuild(fn, mode:)
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
      else
        raise RuntimeError, "unexpected parameter type: #{type}"
      end
    end

    proc do |*args, **kwargs, &block|
      if mode == :tighten
        # remove unreferenced params
        args.slice! params.count unless rest
        kwargs = kwargs.slice(*keys) unless keyrest
      else
        # loosen
      end

      puts "call(#{args}, #{kwargs})"
      fn.call(*args, **kwargs, &block)
    end
  end
end
