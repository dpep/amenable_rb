class Animal
  using Amenable

  def initialize(name)
    @name = name
  end

  amenable def name
    @name
  end

  amenable def self.species
    to_s.downcase
  end
end

class Doggy < Animal
  using Amenable

  def bark(n = 1)
    [ :woof ] * n
  end
  amenable :bark
end


describe Doggy do
  let(:gino) { Doggy.new('Gino') }

  before do
    expect(Amenable).to receive(:call).and_call_original
  end

  describe '#bark' do
    it 'works with the default value' do
      expect(gino.bark).to eq [ :woof ]
    end

    it 'accepts args' do
      expect(gino.bark(2)).to eq [ :woof, :woof ]
    end

    it 'ignores excessive args' do
      expect(gino.bark(2, :x, a: 4)).to eq [ :woof, :woof ]
    end
  end

  describe '#name' do
    it 'works without args' do
      expect(gino.name).to eq 'Gino'
    end

    it 'works with any args' do
      expect(gino.name(:x, a: 1)).to eq 'Gino'
    end
  end

  describe '.species' do
    it 'works without args' do
      expect(Doggy.species).to eq 'doggy'
    end

    it 'works with any args' do
      expect(Doggy.species(:x, a: 1)).to eq 'doggy'
    end
  end
end


class Cat < Animal
  using Amenable

  private amenable def asleep?
    true
  end

  protected def lives
    9
  end
  amenable :lives

  private

  amenable def nice?
    false
  end

  private_class_method def self.agreeable?
    false
  end
  amenable :agreeable?

  class << self
    private

    amenable def evil?
      true
    end
  end
end

describe Cat do
  let(:cat) { Cat.new('Cheshire') }

  describe '#lives' do
    it 'is protected' do
      expect(Cat.protected_instance_methods(false)).to include(:lives)
      expect { cat.lives }.to raise_error(NoMethodError)
    end

    it 'works with any params' do
      expect(cat.send(:lives, :x, :y, a: 1, b: 2)).to be 9
    end
  end

  describe '#asleep?' do
    it 'is private' do
      expect(Cat.private_instance_methods(false)).to include(:asleep?)
      expect { cat.asleep? }.to raise_error(NoMethodError)
    end

    it 'works with any params' do
      expect(cat.send(:asleep?, :x, :y, a: 1, b: 2)).to be true
    end
  end

  describe '#nice?' do
    it 'is private' do
      expect(Cat.private_instance_methods(false)).to include(:nice?)
      expect { cat.nice? }.to raise_error(NoMethodError)
    end

    it 'works with any params' do
      expect(cat.send(:nice?, :x, :y, a: 1, b: 2)).to be false
    end
  end

  describe '.agreeable?' do
    it 'is private' do
      expect(Cat.private_methods(false)).to include(:agreeable?)
      expect { Cat.agreeable? }.to raise_error(NoMethodError)
    end

    it 'works with any params' do
      expect(Cat.send(:agreeable?, :x, :y, a: 1, b: 2)).to be false
    end
  end

  describe '.evil?' do
    it 'is private' do
      expect(Cat.private_methods(false)).to include(:evil?)
      expect { Cat.evil? }.to raise_error(NoMethodError)
    end

    it 'works with any params' do
      expect(Cat.send(:evil?, :x, :y, a: 1, b: 2)).to be true
    end
  end
end
