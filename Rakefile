# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"

# release-please creates the tag and the release commit.
Rake::Task["release:source_control_push"].clear

RSpec::Core::RakeTask.new

task default: :spec

desc "Run tests"
task test: :spec

desc "Benchmark against the standard library Vector"
task :benchmark do
  ruby "benchmark/vector_comparison.rb"
end

desc "Generate API documentation"
YARD::Rake::YardocTask.new(:doc) do |t|
  t.stats_options = ["--list-undoc"]
end

namespace :doc do
  desc "Run the doc examples and check the type tags"
  RSpec::Core::RakeTask.new(:check) do |t|
    t.pattern = "spec/lib/vector2d_{documentation,tags}_spec.rb"
  end
end
