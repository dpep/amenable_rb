###  v0.1.1  (2026-11-03)
- drop Ruby 3.0 and 3.1 (end of life); requires Ruby >= 3.2
- fix: amenable methods no longer run with the first caller's `self` (instances, classes sharing a module, subclasses calling amenable class methods, concurrent first calls)
- fix: amenable methods pass keyword arguments through instead of dropping them (`opt(1, b: 3)` returned the default `b`, `**opts` came back empty)
- fix: keywords sent to a method with no keyword params are passed through as Ruby would bind them (to `*rest` or an open positional slot, e.g. `def m(opts = {})`, and to C methods like `String#encode`) instead of being dropped; they're only stripped when Ruby would reject them
- fix: in a class or module body, `amenable` wraps the instance method even when a class method of the same name exists; `amenable def initialize` now works; module_function methods are wrapped on both the module and its includers
- fix: `amenable` at the top level, and on a plain object's private singleton method, no longer crashes
- fix: `amenable` with an unknown or inherited method raises NoMethodError naming the method and receiver
- fix: a non-lambda proc given a lone Array now auto-splats it as a direct call does (`Amenable.call(proc { |a, b = 2, k: 1| [a, b] }, [5, 1])` returned `[[5, 1], 2]`)
- fix: extra positionals and keywords sent to a non-lambda proc are left for the proc to drop, as a direct call does (`proc { |a,| a }` given `([5, 1], :x)` returned 5 instead of `[5, 1]`)

###  v0.1.0  (2021-07-05)
- readme spec
- test coverage
- simplify ci
- remove wrapper and simplify usage around refinement or .call
- refinement support
- kwarg bugfix

###  v0.0.2  (2021-06-26)
- upgrade to .call / .wrap

###  v0.0.1  (2021-04-07)
- init

