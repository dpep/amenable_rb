# amenable

A magic convenience helper: callers can pass arguments a method doesn't take, and amenable drops them. It must never cause confusion.

## The rule

Follow Ruby's behavior. Amenable removes only what plain Ruby would reject with an ArgumentError: extra positional args and unknown keywords. Any call Ruby already accepts must behave exactly as a direct call does, with the same binding for every arg, keyword and block, the same return value, and the same exceptions from the method body. Judge every change against a direct call.

Decisions that follow:
- If a method has no keyword params, keywords go where Ruby would bind them: to `*rest`, or as a Hash in an open positional slot (`def m(opts = {})`). Amenable strips them only when there's nowhere for them to go.
- Variadic C methods report `[[:rest]]`, so they get everything.
- If an instance method and a class method share a name, `amenable def foo` in a class body wraps the instance method. Wrap the class method from `class << self`.
- `amenable` wraps only methods defined directly on the receiver, not inherited ones.

Known limits, documented rather than fixed: a wrapped method reports the wrapper's `parameters`, `arity` and `source_location`. Curried lambdas and `Symbol#to_proc` expose no signature to strip against.

## Development

- System ruby is too old (the gem needs >= 3.2). Run `RBENV_VERSION=4.0.6 rbenv exec bundle exec rspec`; 3.4.10 is also installed.
- `Gemfile.lock` is gitignored. If bundler fails to load, a stale local lock may pin an ancient bundler: delete it and run `bundle install`.
- `spec/readme_spec.rb` runs the README's Dog example. If you change one, change the other.
