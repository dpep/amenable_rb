# amenable

A magic convenience helper: callers can pass arguments a method doesn't take, and amenable drops them. It must never cause confusion.

## The rule

Follow Ruby's behavior. Amenable only removes what plain Ruby would reject with an ArgumentError (too many positional args, unknown keywords). Any call Ruby already accepts must behave exactly as it does without amenable: the same binding for every arg, keyword and block, the same return value, and the same exceptions from the method body. Judge every change against a direct call.

Decisions that follow from it:
- Keywords sent to a method with no keyword params go wherever Ruby would bind them: to `*rest`, or as a Hash in an open positional slot (`def m(opts = {})`). They're stripped only when there's nowhere for them to go. C methods report `[[:rest]]` and get everything.
- When an instance method and a class method share a name, `amenable def foo` in a class body wraps the instance method. The class one needs `class << self`.
- `amenable` wraps only methods defined directly on the receiver, not inherited ones.

Known limits, documented rather than fixed: a wrapped method reports the wrapper's `parameters`/`arity`/`source_location`, and curried lambdas and `Symbol#to_proc` don't expose a signature to strip against.

## Development

- Ruby >= 3.2. System ruby is too old here, so use `RBENV_VERSION=4.0.6 rbenv exec bundle exec rspec` (3.4.10 is also installed).
- `Gemfile.lock` is gitignored. A stale local copy can pin an ancient bundler that won't load on new Rubies; delete it and run `bundle install`.
- `spec/readme_spec.rb` runs the README's example, so keep them in sync.
