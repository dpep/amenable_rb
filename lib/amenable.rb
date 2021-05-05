require 'amenable/version'

module Amenable
  extend self

  refine Object do
    def amenable(name)
      if respond_to?(name) # class method
        original_method = singleton_class.instance_method(name)
        definer = method(:define_singleton_method)
      else # instance method
        original_method = instance_method(name)
        definer = method(:define_method)
      end
      # byebug

      # rebuild
      # remount
    end
  end

  refine Proc do
    def call(*args)
      Amenable.call(self, *args)
    end
  end

  def call(target, *args, **kwargs, &block)
    fn = case target
    when Symbol
      method(target)
    when Method, Proc
      target
    else
      if target.respond_to?(:call)
        target
      else
        raise NotImplementedError
      end
    end

    rebuild(fn).call(*args, **kwargs, &block)
  end

  # def amenable(target)
  #   fn, redefiner = parse(target)
  #   rebuild(fn)

  #   # remount
  # end

  private

  def parse fn
    case fn
    when Symbol
      fn = method(fn)
      redefiner = method(:define_method)
    when Method
      redefiner = method(:define_method)
    when Proc
    end

    [ fn, redefiner ]
  end

  def rebuild(fn)
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
      # when :block
      else
        raise RuntimeError, "unexpected parameter type: #{type}"
      end
    end

    puts "rebuild: #{params} | #{keys}"

    proc do |*args, **kwargs, &block|
      # remove unreferenced params
      args.slice! params.count unless rest
      kwargs = kwargs.slice(*keys) unless keyrest

      # fill in missing params
      # puts "missing: #{params.count - args.count} args"
      # puts "missing: ", (keys - kwargs.keys)
      args += [ nil ] * (params.count - args.count)
      (keys - kwargs.keys).each {|k| kwargs[k] = nil }

      puts "call(#{args}, #{kwargs}, #{block_given?})"
      fn.call(*args, **kwargs, &block)
    end
  end
end
