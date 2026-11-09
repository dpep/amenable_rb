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
  s.files       = `git ls-files * ':!:spec' ':!:CLAUDE.md'`.split("\n")

  s.metadata = {
    "changelog_uri" => "#{s.homepage}/blob/main/CHANGELOG.md",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => s.homepage,
  }

  s.required_ruby_version = ">= 3.2"

  s.add_development_dependency 'debug'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov', '>= 1'
end
