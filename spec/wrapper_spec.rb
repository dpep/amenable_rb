using Amenable

describe 'amenable wrapper' do
  describe 'receiver' do
    it 'binds each call to its own receiver' do
      klass = Class.new do
        def initialize(name) = @name = name
        amenable def name = @name
      end

      expect(klass.new('a').name).to eq 'a'
      expect(klass.new('b').name).to eq 'b'
    end

    it 'does not leak self across classes sharing a module' do
      mixin = Module.new { amenable def who = self.class }
      one = Class.new { include mixin }
      two = Class.new { include mixin }

      expect([ one.new.who, two.new.who ]).to eq [ one, two ]
    end

    it 'binds class methods to the calling subclass' do
      parent = Class.new { amenable def self.me = self }
      child = Class.new(parent)

      expect(child.me).to be child
      expect(parent.me).to be parent
    end

    it 'binds the right receiver under concurrent first calls' do
      klass = Class.new do
        def initialize(name) = @name = name
        amenable def name = (sleep 0.001; @name)
      end

      results = 20.times.map { |i| Thread.new { klass.new(i).name } }.map(&:value)
      expect(results).to eq 20.times.to_a
    end
  end

  describe 'keywords' do
    let(:klass) do
      Class.new do
        amenable def req(a:) = a
        amenable def opt(a, b: 2) = [ a, b ]
        amenable def rest(**o) = o
      end
    end

    it 'passes required keywords through' do
      expect(klass.new.req(a: 1)).to eq 1
    end

    it 'passes optional keywords through' do
      expect(klass.new.opt(1, b: 3)).to eq [ 1, 3 ]
    end

    it 'passes keywords to **rest' do
      expect(klass.new.rest(a: 1)).to eq(a: 1)
    end

    it 'keeps an explicit Hash positional' do
      klass = Class.new { amenable def pos(h) = h }
      expect(klass.new.pos({ a: 1 })).to eq(a: 1)
    end

    it 'still strips unknown keywords' do
      expect(klass.new.opt(1, :x, b: 3, c: 4)).to eq [ 1, 3 ]
    end
  end
end
