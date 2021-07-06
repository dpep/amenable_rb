Amenable
======
Removes exessive parameters from function calls.


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
