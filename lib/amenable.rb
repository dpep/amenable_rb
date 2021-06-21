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
      # remove unreferenced params
      args.slice! params.count unless rest
      kwargs = kwargs.slice(*keys) unless keyrest

      fn.call(*args, **kwargs, &block)
    end
  end
end