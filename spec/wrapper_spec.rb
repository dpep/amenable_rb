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
end
