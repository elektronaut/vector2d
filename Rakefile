# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

# release-please creates the tag and the release commit.
Rake::Task["release:source_control_push"].clear

RSpec::Core::RakeTask.new

task default: :spec

desc "Run tests"
task test: :spec
