# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{vector2d}
  s.version = "0.5.2"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Inge J\303\270rgensen"]
  s.date = %q{2009-05-20}
  s.email = %q{inge@elektronaut.no}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/vector2d.rb",
     "test/test_helper.rb",
     "test/vector2d_test.rb",
     "vector2d.gemspec"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/elektronaut/vector2d}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{vector2d}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Vector2d allows for easy handling of two-dimensionals coordinates and vectors}
  s.test_files = [
    "test/test_helper.rb",
     "test/vector2d_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
