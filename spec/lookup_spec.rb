using Amenable

describe 'amenable method lookup' do
  context 'when a class method shares the name' do
    let(:klass) do
      Class.new do
        def self.call(x) = new.call(x)
        amenable def call(x) = "instance #{x}"
      end
    end

    it 'wraps the instance method' do
      expect(klass.new.call(1, 2)).to eq 'instance 1'
    end

    it 'leaves the class method alone' do
      expect { klass.call(1, 2) }.to raise_error(ArgumentError)
    end
  end

  it 'wraps initialize' do
    klass = Class.new do
      attr_reader :name
      amenable def initialize(name) = @name = name
    end

    expect(klass.new('a', 'extra').name).to eq 'a'
    expect(klass.private_instance_methods(false)).to include(:initialize)
  end

  it 'wraps a class instance method named like a Class hook' do
    klass = Class.new { amenable def inherited(a) = "inst #{a}" }

    expect(klass.new.inherited(1, 2)).to eq 'inst 1'
    expect(Class.new(klass).superclass).to be klass
  end

  it 'wraps a module instance method named like a Module hook' do
    mixin = Module.new { amenable def included(a) = "inst #{a}" }
    host = Class.new { include mixin }

    expect(host.new.included(1, 2)).to eq 'inst 1'
  end

  context 'with module_function' do
    let(:mod) do
      Module.new do
        module_function

        amenable def helper(a) = "helper #{a}"
      end
    end

    it 'wraps the singleton copy' do
      expect(mod.helper(1, 2)).to eq 'helper 1'
    end

    it 'wraps the private instance copy' do
      mixin = mod
      host = Class.new { include mixin }
      expect(host.new.send(:helper, 1, 2)).to eq 'helper 1'
      expect(host.private_instance_methods).to include(:helper)
    end
  end

  it 'leaves an unrelated singleton method of the same name alone' do
    mod = Module.new do
      def self.both(a) = "singleton #{a}"
      amenable def both(a) = "instance #{a}"
    end

    expect { mod.both(1, 2) }.to raise_error(ArgumentError)
  end

  context 'on a plain object' do
    let(:obj) { Object.new }

    it 'wraps a singleton method' do
      def obj.foo(a) = a
      obj.amenable(:foo)

      expect(obj.foo(1, 2)).to eq 1
    end

    it 'wraps a private singleton method and keeps it private' do
      def obj.bar(a) = a
      obj.singleton_class.send(:private, :bar)
      obj.amenable(:bar)

      expect(obj.send(:bar, 1, 2)).to eq 1
      expect { obj.bar(1) }.to raise_error(NoMethodError)
    end
  end
end
