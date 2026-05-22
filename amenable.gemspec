require_relative "lib/amenable/version"

Gem::Specification.new do |s|
  s.name        = 'amenable'
  s.version     = Amenable::VERSION
  s.authors     = ['Daniel Pepper']
  s.summary     = 'Amenable'
  s.description = <<~DESCRIPTION
    A refinement that strips excess positional and keyword arguments
    from method calls, so callers can pass extras without raising
    ArgumentError.
  DESCRIPTION
  s.homepage    = "https://github.com/dpep/amenable_rb"
  s.license     = 'MIT'
  s.files       = `git ls-files * ':!:spec'`.split("\n")

  s.required_ruby_version = ">= 3"

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
end
