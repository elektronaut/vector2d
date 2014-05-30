# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "vector2d/version"

Gem::Specification.new do |s|
  s.name        = %q{vector2d}
  s.version     = Vector2d::VERSION
  s.authors     = ["Inge Jørgensen"]
  s.email       = ["inge@elektronaut.no"]
  s.homepage    = %q{http://github.com/elektronaut/vector2d}
  s.summary     = %q{Library for handling two-dimensional vectors}
  s.description = %q{Vector2d allows for easy handling of two-dimensionals coordinates and vectors}
  s.license     = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.9.2'

  # specify any dependencies here; for example:
  s.add_development_dependency "rake", "~> 10.3"
  s.add_development_dependency "rspec", "~> 2.1"
end
