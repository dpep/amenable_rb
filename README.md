Amenable
======
Removes excessive parameters from function calls.

The rule: amenable drops only the arguments Ruby would reject with `ArgumentError`. Any call Ruby already accepts behaves exactly as it would without amenable.


```ruby
require 'amenable'

class Dog
  using Amenable

  amenable def bark(n = 1)
    ([ :woof ] * n).join(" ")
  end
end


Dog.new.bark
> "woof"

Dog.new.bark(2)
> "woof woof"

Dog.new.bark(2, 3, 4, foo: 5)
> "woof woof"
```


## Usage

```ruby
gem "amenable"  # requires Ruby >= 3.3
```

Activate the refinement with `using Amenable`, then wrap a method as you define it (`amenable def bark ...`) or afterwards by name (`amenable :bark`). It works on instance, private, protected, and class methods (`amenable def self.build`), on `module_function` methods, and at the top level.

For a Method or Proc you already have, skip the refinement and use `Amenable.call(fn, *args, **kwargs, &block)`:

```ruby
Amenable.call(->(a) { a * 2 }, 3, 4, x: 1)
> 6
```


## Keywords

Extra keywords are dropped when the method can't take them. If it has an open positional slot, they land there as a Hash, as in plain Ruby:

```ruby
class Greeter
  using Amenable

  amenable def hello(name, greeting: "hi")
    "#{greeting} #{name}"
  end

  amenable def configure(opts = {})
    opts
  end
end


Greeter.new.hello("bob", greeting: "yo", volume: 11)
> "yo bob"

Greeter.new.configure(verbose: true)
> {verbose: true}
```

Missing arguments still raise. Amenable removes; it never fills in.


## Limits

- Only wraps methods defined directly on the receiver, not inherited ones (raises `NoMethodError`).
- When a class method and an instance method share a name, `amenable def foo` in the class body wraps the instance method. Use `class << self` to wrap the class one.
- Wrapped methods report the wrapper's `parameters`, `arity`, and `source_location`.
- Curried lambdas and `Symbol#to_proc` can't be stripped: their real signature isn't visible.


----
## Contributing

Yes please  :)

1. Fork it
1. Create your feature branch (`git checkout -b my-feature`)
1. Ensure the tests pass (`bundle exec rspec`)
1. Commit your changes (`git commit -am 'awesome new feature'`)
1. Push your branch (`git push origin my-feature`)
1. Create a Pull Request


----
![Gem](https://img.shields.io/gem/dt/amenable?style=plastic)
[![codecov](https://codecov.io/gh/dpep/amenable_rb/branch/main/graph/badge.svg)](https://codecov.io/gh/dpep/amenable_rb)
