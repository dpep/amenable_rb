###  Unreleased
- drop Ruby 3.0 and 3.1 (end of life); requires Ruby >= 3.2
- fix: amenable methods no longer run with the first caller's `self` (instances, classes sharing a module, subclasses calling amenable class methods, concurrent first calls)
- fix: amenable methods pass keyword arguments through instead of dropping them (`opt(1, b: 3)` returned the default `b`, `**opts` came back empty)
- fix: in a class or module body, `amenable` wraps the instance method even when a class method of the same name exists; `amenable def initialize` now works; module_function methods are wrapped on both the module and its includers
- fix: `amenable` at the top level, and on a plain object's private singleton method, no longer crashes
- fix: `amenable` with an unknown or inherited method raises NoMethodError naming the method and receiver

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

