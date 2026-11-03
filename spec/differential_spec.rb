using Amenable

# A seeded differential fuzz: random signatures, random calls. Any call a
# direct call accepts must behave identically through Amenable.call and
# through an amenable-wrapped method.
module Differential
  SEED = 2026
  SIGNATURES = 1000
  CALLS_PER_SIGNATURE = 4

  BLOCK = proc { :yielded }

  # anonymous params can only be forwarded, so forward them here to see them
  module Sink
    def self.rest(*a) = a
    def self.keyrest(**k) = k
    def self.block(&b) = (b ? b.call : :no_block)
    def self.all(*a, **k, &b) = [ a, k, b ? b.call : :no_block ]
  end

  FORWARD = {
    rest: 'Differential::Sink.rest(*)',
    keyrest: 'Differential::Sink.keyrest(**)',
    block: 'Differential::Sink.block(&)',
    all: 'Differential::Sink.all(...)',
  }.freeze

  class Generator
    def initialize(seed) = @rng = Random.new(seed)

    # returns [params, named params, anonymous params, keyword names, block kind]
    def signature(flavor)
      method = flavor == :method
      params = []
      names = []
      anon = []
      keys = []
      n = 0
      named = ->(param, name) { params << param; names << name }
      positional = -> { named.call("a#{n += 1}", "a#{n}") }

      rand(3).times { positional.call }

      return [ params << '...', names, [ :all ], keys, :forwarded ] if method && rand(8).zero?

      optional = rand(3)
      optional.times { n += 1; named.call("a#{n} = :d#{n}", "a#{n}") }

      rest = pick(nil, nil, :named, method ? :anon : :named)
      case rest
      when :named then named.call('*r', 'r')
      when :anon then params << '*'; anon << :rest
      end
      rand(3).times { positional.call } if rest || optional > 0

      rand(3).times { |i| named.call("k#{i}: :kd#{i}", "k#{i}"); keys << "k#{i}" }
      if rand(4).zero?
        named.call('kq:', 'kq')
        keys << 'kq'
      end

      case pick(nil, nil, :named, :nil, method ? :anon : :named)
      when :named then named.call('**kr', 'kr')
      when :anon then params << '**'; anon << :keyrest
      when :nil then params << '**nil' if keys.empty?
      end

      block = pick(nil, :named, method ? :anon : :named)
      case block
      when :named then params << '&b'
      when :anon then params << '&'; anon << :block
      end

      [ params, names, anon, keys, block ]
    end

    def body(names, anon, block, method)
      parts = [ "{ #{names.map { |name| "#{name}: #{name}" }.join(', ')} }" ]
      parts += anon.map { |kind| FORWARD.fetch(kind) }
      parts << '(b ? b.call : :no_block)' if block == :named
      parts << '(block_given? ? yield : :no_block)' if block.nil? && method
      "[ #{parts.join(', ')} ]"
    end

    # returns [source, keyword names]
    def source(flavor)
      params, names, anon, keys, block = signature(flavor)
      body = body(names, anon, block, flavor == :method)

      case flavor
      when :method
        [ "def m(#{params.join(', ')}) = #{body}", keys ]
      when :lambda
        [ "->(#{params.join(', ')}) { #{body} }", keys ]
      when :proc
        src = "proc { |#{params.join(', ')}| #{body} }"
        # `|a1,|` reports the same parameters as `|a1|` but auto-splats
        [ pick(src, src, src, 'proc { |a1,| [ a1 ] }', 'proc { [ _1 ] }', 'proc { [ _1, _2 ] }'), keys ]
      end
    end

    def call(keys)
      args = Array.new(rand(5)) { value }
      args = [ Array.new(2 + rand(2)) { rand(10) } ] if rand(4).zero? # auto-splat bait
      kwargs = Array.new(rand(4)) { [ pick(*keys.map(&:to_sym), :kq, :zz, 'k0', :kr), rand(100) ] }.to_h
      [ args, kwargs, rand(2).zero? ]
    end

    def flavor = pick(:method, :method, :lambda, :proc)

    private

    def rand(n) = @rng.rand(n)
    def pick(*options) = options[rand(options.size)]

    def value
      pick(rand(100), [ rand(10), rand(10) ], { k0: rand(10) }, { 'k0' => rand(10) }, {}, :"v#{rand(10)}")
    end
  end

  # never passes `**{}`: it isn't a no-op, it stops a proc auto-splatting
  def self.invoke((args, kwargs, block))
    block = block ? BLOCK : nil
    kwargs.empty? ? yield(args, nil, block) : yield(args, kwargs, block)
  end

  def self.outcome
    [ :ok, yield ]
  rescue StandardError => e
    [ :error, e.class, e.message ]
  end
end

describe 'Amenable, against a direct call' do
  it 'behaves identically for every call Ruby accepts' do
    gen = Differential::Generator.new(Differential::SEED)
    accepted = 0

    Differential::SIGNATURES.times do
      flavor = gen.flavor
      src, keys = gen.source(flavor)

      if flavor == :method
        plain, wrapped = Array.new(2) { Class.new { class_eval(src) } }
        wrapped.amenable(:m)
        direct_fn = plain.new.method(:m)
        wrapped_obj = wrapped.new
      else
        direct_fn = Differential.module_eval(src)
      end

      Differential::CALLS_PER_SIGNATURE.times do
        call = gen.call(keys)

        direct = Differential.outcome do
          Differential.invoke(call) { |a, k, b| k ? direct_fn.call(*a, **k, &b) : direct_fn.call(*a, &b) }
        end
        next unless direct.first == :ok

        accepted += 1
        context = "#{src} called with #{call.inspect}"

        through_call = Differential.outcome do
          Differential.invoke(call) { |a, k, b| k ? Amenable.call(direct_fn, *a, **k, &b) : Amenable.call(direct_fn, *a, &b) }
        end
        expect(through_call).to eq(direct), "Amenable.call: #{context}"

        next unless wrapped_obj

        through_wrapper = Differential.outcome do
          Differential.invoke(call) { |a, k, b| k ? wrapped_obj.m(*a, **k, &b) : wrapped_obj.m(*a, &b) }
        end
        expect(through_wrapper).to eq(direct), "wrapped method: #{context}"
      end
    end

    # guard against a generator change that quietly stops exercising anything
    expect(accepted).to be > Differential::SIGNATURES
  end
end
