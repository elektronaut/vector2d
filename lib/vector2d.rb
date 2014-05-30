# encoding: utf-8

require 'vector2d/calculations'
require 'vector2d/coercions'
require 'vector2d/fitting'
require 'vector2d/properties'
require 'vector2d/transformations'
require 'vector2d/version'

class Vector2d
  extend Vector2d::Calculations::ClassMethods
  include Vector2d::Calculations
  include Vector2d::Coercions
  include Vector2d::Fitting
  include Vector2d::Properties
  include Vector2d::Transformations

  class << self
    # Creates a new vector.
    # The following examples are all valid:
    #
    #   Vector2d.parse(150, 100)
    #   Vector2d.parse(150.0, 100.0)
    #   Vector2d.parse("150x100")
    #   Vector2d.parse("150.0x100.0")
    #   Vector2d.parse([150,100})
    #   Vector2d.parse({:x => 150, :y => 100})
    #   Vector2d.parse({"x" => 150.0, "y" => 100.0})
    #   Vector2d.parse(Vector2d.new(150, 100))
    def parse(arg, second_arg=nil)
      return self.new(arg, second_arg) if !second_arg.nil?

      case arg
      when Vector2d
        arg
      when Array
        self.parse(*arg)
      when Numeric
        self.new(arg, arg)
      when /^[\s]*[\d\.]*[\s]*x[\s]*[\d\.]*[\s]*$/
        self.new(*arg.split("x").map(&:to_f))
      when Hash
        parse_hash(arg.dup)
      else
        raise ArgumentError, "unsupported argument type #{arg.class}"
      end
    end

    private

    def parse_hash(hash)
      hash[:x] ||= hash['x'] if hash.has_key?('x')
      hash[:y] ||= hash['y'] if hash.has_key?('y')
      self.new(hash[:x], hash[:y])
    end
  end

  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  # Compare two vectors
  def ==(comp)
    comp.x == x && comp.y == y
  end
end
