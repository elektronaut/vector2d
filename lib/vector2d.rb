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

  # Matches a single coordinate in a string, with an optional sign and
  # an optional fractional part.
  COORDINATE_EXPRESSION = /[+-]?(?:\d+(?:\.\d+)?|\.\d+)/

  # Matches the string form of a vector, "150x100" or "150,100".
  # Whitespace is insignificant, the separator is case insensitive, and
  # either coordinate can be left out to mean zero.
  STRING_EXPRESSION = /
    \A\s*(#{COORDINATE_EXPRESSION})?\s*[x,]\s*(#{COORDINATE_EXPRESSION})?\s*\z
  /xi

  private_constant :COORDINATE_EXPRESSION, :STRING_EXPRESSION

  class << self
    # Creates a vector from an angle in radians, with an optional
    # length. Angles are measured counterclockwise from the positive x
    # axis, the same convention #angle follows.
    #
    #   Vector2d.from_angle(0)                 # => Vector2d(1.0,0.0)
    #   Vector2d.from_angle(Math::PI / 4)      # => Vector2d(0.7071..,0.7071..)
    #   Vector2d.from_angle(Math::PI / 4, 2.0) # => Vector2d(1.4142..,1.4142..)
    #
    # Coordinates are always floats. This is the inverse of #to_polar.
    #
    #   length, angle = Vector2d(2, 3).to_polar
    #   Vector2d.from_angle(angle, length) # => Vector2d(2.0,3.0)
    #
    # Raises ArgumentError unless both arguments are numbers.
    def from_angle(angle, length = 1.0)
      angle = coordinate(angle)
      length = coordinate(length)
      new(Math.cos(angle) * length, Math.sin(angle) * length)
    end

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
    # Strings are either "150x100" or "150,100", optionally signed and
    # case insensitive. Coordinates keep their type, so "150x100" gives
    # integers and "150.0x100" gives a float and an integer. An omitted
    # coordinate is zero, as in "x100".
    #
    #   Vector2d.parse("-150X100") # => Vector2d(-150,100)
    #   Vector2d.parse("150, 100") # => Vector2d(150,100)
    #   Vector2d.parse("x100")     # => Vector2d(0,100)
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
      match = STRING_EXPRESSION.match(str)
      raise ArgumentError, "not a valid string input: #{str.inspect}" unless match

      new(string_coordinate(match[1]), string_coordinate(match[2]))
    end

    def string_coordinate(value)
      return 0 if value.nil?

      value.include?(".") ? value.to_f : value.to_i
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
  #   Vector2d(2, 3) == [2, 3]         # => false
  #
  def ==(other)
    other.is_a?(Vector2d) && other.x == x && other.y == y
  end

  # Compares two vectors for hash equality. Unlike #==, the other object
  # must be a vector of the same class, and the coordinates must be of
  # the same type.
  #
  #   Vector2d(2, 3).eql?(Vector2d(2, 3))     # => true
  #   Vector2d(2, 3).eql?(Vector2d(2.0, 3.0)) # => false
  #
  def eql?(other)
    other.instance_of?(self.class) && x.eql?(other.x) && y.eql?(other.y)
  end

  # Hash value of the vector, consistent with #eql?.
  #
  #   Vector2d(2, 3).hash == Vector2d(2, 3).hash # => true
  #
  def hash
    [self.class, x, y].hash
  end
end

# Instantiates a Vector2d
#
#   Vector2d(2, 3) # => Vector2d(2,3)
#
def Vector2d(*)
  Vector2d.parse(*)
end
