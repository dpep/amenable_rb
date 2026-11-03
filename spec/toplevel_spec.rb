using Amenable

# a top-level def is a private method on Object, callable from anywhere
amenable def amenable_toplevel_spec(a) = a
amenable def self.amenable_main_spec(a) = a

describe 'amenable at the top level' do
  it 'wraps the method' do
    expect(TOPLEVEL_BINDING.receiver.send(:amenable_toplevel_spec, 1, 2)).to eq 1
  end

  it 'wraps it for every receiver and keeps it private' do
    expect(Object.private_method_defined?(:amenable_toplevel_spec, false)).to be true
    expect(amenable_toplevel_spec(1, 2)).to eq 1
  end

  it 'wraps a singleton method on main' do
    expect(TOPLEVEL_BINDING.receiver.amenable_main_spec(1, 2)).to eq 1
  end
end
