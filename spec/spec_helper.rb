# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "vector2d"
require "rspec/its"

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |file| require file }
