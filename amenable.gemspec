package_name = Dir.glob('*.gemspec')[0].split('.')[0]
require_relative "lib/#{package_name}/version"

package = Amenable


Gem::Specification.new do |s|
  s.name        = package_name
  s.version     = package.const_get 'VERSION'
  s.authors     = ['Daniel Pepper']
  s.summary     = package.to_s
  s.description = 'Flexibility when you need it.'
  s.homepage    = "https://github.com/dpep/#{package_name}_rb"
  s.license     = 'MIT'

  s.files       = Dir.glob('lib/**/*')
  s.test_files  = Dir.glob('spec/**/*_spec.rb')

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'codecov'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
end
