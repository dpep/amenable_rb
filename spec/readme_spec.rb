class Dog
  using Amenable

  amenable def bark(n = 1)
    ([ :woof ] * n).join(" ")
  end
end

describe Dog do
  it 'barks' do
    expect(Dog.new.bark).to eq "woof"
  end

  it 'barks n times' do
    expect(Dog.new.bark(2)).to eq "woof woof"
  end

  it 'ignores excessive parameters' do
    expect(Dog.new.bark(2, 3, :x, a: 1)).to eq "woof woof"
  end
end
