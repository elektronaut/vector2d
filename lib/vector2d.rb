# frozen_string_literal: true

require_relative "vector2d/calculations"
require_relative "vector2d/coercions"
require_relative "vector2d/fitting"
require_relative "vector2d/properties"
require_relative "vector2d/transformations"
require_relative "vector2d/version"

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
    #   Vector2d.parse({x: 150, y: 100})
    #   Vector2d.parse({"x" => 150.0, "y" => 100.0})
    #   Vector2d.parse(Vector2d(150, 100))
    #
    # Raises ArgumentError unless both coordinates resolve to numbers.
    def parse(arg, second_arg = nil)
      return parse_single_arg(arg) if second_arg.nil?

      new(coordinate(arg), coordinate(second_arg))
    end

    private

    def parse_single_arg(arg)
      return arg if arg.is_a?(Vector2d)
      return parse_array(arg) if arg.is_a?(Array)
      return parse_str(arg) if arg.is_a?(String)
      return parse_hash(arg) if arg.is_a?(Hash)

      value = coordinate(arg)
      new(value, value)
    end

    def parse_array(array)
      case array.length
      when 1 then parse_single_arg(array.first)
      when 2 then new(coordinate(array[0]), coordinate(array[1]))
      else
        raise ArgumentError, "expected 1 or 2 coordinates, got #{array.length}"
      end
    end

    def parse_hash(hash)
      new(coordinate(hash[:x] || hash["x"]),
          coordinate(hash[:y] || hash["y"]))
    end

    def coordinate(value)
      raise ArgumentError, "not a valid coordinate: #{value.inspect}" unless value.is_a?(Numeric)

      value
    end

    def parse_str(str)
      raise ArgumentError, "not a valid string input" unless /^\s*[\d.]*\s*x\s*[\d.]*\s*$/.match?(str)

      x, y = str.split("x")
      new(x.to_f, y.to_f)
    end
  end

  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  # Compares two vectors
  #
  #   Vector2d(2, 3) == Vector2d(2, 3) # => true
  #   Vector2d(2, 3) == Vector2d(1, 0) # => false
  #
  def ==(other)
    other.x == x && other.y == y
  end
end

# Instantiates a Vector2d
#
#   Vector2d(2, 3) # => Vector2d(2,3)
#
def Vector2d(*)
  Vector2d.parse(*)
end
