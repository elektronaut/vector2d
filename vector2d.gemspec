# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require "vector2d/version"

Gem::Specification.new do |s|
  s.name        = "vector2d"
  s.version     = Vector2d::VERSION
  s.authors     = ["Inge Jørgensen"]
  s.email       = ["inge@elektronaut.no"]
  s.homepage    = "http://github.com/elektronaut/vector2d"
  s.summary     = "Library for handling two-dimensional vectors"
  s.description = "Vector2d allows for easy handling of two-dimensional " \
                  "coordinates and vectors"
  s.license     = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`
                    .split("\n")
                    .map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.7.0"

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.8"
  s.add_development_dependency "rspec-its", "~> 1.3"
  s.add_development_dependency "simplecov", "~> 0.17.1"
  s.add_dependency "contracts", "~> 0.16.0"
end
