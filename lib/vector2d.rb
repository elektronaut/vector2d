# frozen_string_literal: true

# The one place the types Vector2d.parse accepts are written out. Every
# parameter that is coerced into a vector takes this union.
#
# @!macro [new] coercible
#  @param $1 [Vector2d, Array, String, Hash, Integer, Float, Rational,
#    BigDecimal, ::Vector, ::Matrix] anything Vector2d.parse accepts

require_relative "vector2d/angles"
require_relative "vector2d/arithmetic"
require_relative "vector2d/comparison"
require_relative "vector2d/componentwise"
require_relative "vector2d/constructors"
require_relative "vector2d/conversions"
require_relative "vector2d/coordinates"
require_relative "vector2d/deprecation"
require_relative "vector2d/dimensions"
require_relative "vector2d/interpolation"
require_relative "vector2d/lengths"
require_relative "vector2d/matrix_interop"
require_relative "vector2d/projection"
require_relative "vector2d/version"

# An immutable two dimensional vector.
#
# Coordinates are real numbers, and keep the type they were given.
# Integer coordinates stay exact through arithmetic with integers, and
# widen to floats when a float is involved.
#
#   Vector2d(2, 3) * 2   # => Vector2d(4,6)
#   Vector2d(2, 3) * 0.5 # => Vector2d(1.0,1.5)
#
# Instances are frozen, so every operation returns a new vector instead
# of changing the receiver. New vectors are built through #build, which
# a subclass overrides to carry its own state across operations.
#
# .parse is the permissive constructor, and Vector2d() is shorthand for
# it. .new takes exactly two coordinates.
#
#   Vector2d("2x3")    # => Vector2d(2,3)
#   Vector2d.new(2, 3) # => Vector2d(2,3)
#
class Vector2d
  extend Vector2d::Angles::ClassMethods
  extend Vector2d::Constructors
  extend Vector2d::Coordinates
  extend Vector2d::Projection::ClassMethods
  include Vector2d::Angles
  include Vector2d::Arithmetic
  include Vector2d::Comparison
  include Vector2d::Componentwise
  include Vector2d::Conversions
  include Vector2d::Coordinates
  include Vector2d::Deprecation
  include Vector2d::Dimensions
  include Vector2d::Interpolation
  include Vector2d::Lengths
  include Vector2d::MatrixInterop
  include Vector2d::Projection

  # Matches a single coordinate in a string, with an optional sign and
  # an optional fractional part.
  COORDINATE_EXPRESSION = /[+-]?(?:\d+(?:\.\d+)?|\.\d+)/

  # Matches the string form of a vector, "150x100" or "150,100".
  # Whitespace is insignificant, the separator is case insensitive, and
  # either coordinate can be left out to mean zero.
  STRING_EXPRESSION = /
    \A\s*(#{COORDINATE_EXPRESSION})?\s*[x,]\s*(#{COORDINATE_EXPRESSION})?\s*\z
  /xi

  # Stands in for an omitted second argument to .parse, so an explicit
  # nil can be rejected as a coordinate.
  NO_ARGUMENT = Object.new.freeze

  private_constant :COORDINATE_EXPRESSION, :STRING_EXPRESSION, :NO_ARGUMENT

  class << self
    # Builds a new vector of this class from two coordinates, the way
    # .parse and .from_angle do. Override it in a subclass whose
    # constructor requires more than the coordinates, and see #build for
    # the instance side.
    #
    #   class Labeled < Vector2d
    #     attr_reader :label
    #
    #     def initialize(x, y, label = nil)
    #       @label = label
    #       super(x, y)
    #     end
    #
    #     def self.build(x, y) = new(x, y, "unlabeled")
    #   end
    #
    #   Labeled.parse("2x3").label # => "unlabeled"
    #
    # @param x [Integer, Float, Rational, BigDecimal] the x coordinate
    # @param y [Integer, Float, Rational, BigDecimal] the y coordinate
    # @return [Vector2d] a vector of this class
    def build(x, y)
      new(x, y)
    end

    # Parses a vector out of any of the forms below, and is the
    # permissive counterpart to .new, which takes exactly two
    # coordinates. Vector2d() is shorthand for this method.
    #
    #   Vector2d.parse(150, 100)
    #   Vector2d.parse(150.0, 100.0)
    #   Vector2d.parse("150x100")
    #   Vector2d.parse("150.0x100.0")
    #   Vector2d.parse([150,100])
    #   Vector2d.parse({x: 150, y: 100})
    #   Vector2d.parse({"x" => 150.0, "y" => 100.0})
    #   Vector2d.parse(Vector2d(150, 100))
    #   Vector2d.parse(Vector[150, 100])
    #   Vector2d.parse(Matrix[[150], [100]])
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
    # Raises ArgumentError unless both coordinates resolve to real
    # numbers. Complex numbers are not coordinates, and are rejected.
    #
    #   Vector2d.parse(150, nil)         # => ArgumentError
    #   Vector2d.parse(Complex(1, 2), 3) # => ArgumentError
    #
    # @param arg [Vector2d, Array, String, Hash, Integer, Float,
    #   Rational, BigDecimal, ::Vector, ::Matrix] the vector, in any of
    #   the forms above, or its x coordinate
    # @param second_arg [Integer, Float, Rational, BigDecimal]
    #   the y coordinate, when the first argument is the x coordinate
    # @return [Vector2d] a vector of this class, unless the argument is
    #   already a vector, which is returned as it is
    def parse(arg, second_arg = NO_ARGUMENT)
      return parse_single_arg(arg) if NO_ARGUMENT.equal?(second_arg)

      build(coordinate(arg), coordinate(second_arg))
    end

    private

    def parse_single_arg(arg)
      return arg if arg.is_a?(Vector2d)
      return parse_array(arg) if arg.is_a?(Array)
      return parse_str(arg) if arg.is_a?(String)
      return parse_hash(arg) if arg.is_a?(Hash)
      return parse_vector(arg) if MatrixInterop.vector?(arg)
      return parse_matrix(arg) if MatrixInterop.matrix?(arg)

      value = coordinate(arg)
      build(value, value)
    end

    def parse_array(array)
      case array.length
      when 1 then parse_single_arg(array.first)
      when 2 then build(coordinate(array[0]), coordinate(array[1]))
      else
        raise ArgumentError, "expected 1 or 2 coordinates, got #{array.length}"
      end
    end

    def parse_hash(hash)
      build(coordinate(hash[:x] || hash["x"]),
            coordinate(hash[:y] || hash["y"]))
    end

    def parse_matrix(matrix)
      shape = [matrix.row_count, matrix.column_count]
      unless [[2, 1], [1, 2]].include?(shape)
        raise ArgumentError,
              "expected a 2x1 or 1x2 matrix, got #{shape.join('x')}"
      end

      values = matrix.to_a.flatten
      build(coordinate(values[0]), coordinate(values[1]))
    end

    def parse_vector(vector)
      raise ArgumentError, "expected 2 coordinates, got #{vector.size}" unless vector.size == 2

      build(coordinate(vector[0]), coordinate(vector[1]))
    end

    def parse_str(str)
      match = STRING_EXPRESSION.match(str)
      raise ArgumentError, "not a valid string input: #{str.inspect}" unless match

      build(string_coordinate(match[1]), string_coordinate(match[2]))
    end

    def string_coordinate(value)
      return 0 if value.nil?

      value.include?(".") ? value.to_f : value.to_i
    end
  end

  # The coordinates.
  #
  #   Vector2d(2, 3).x # => 2
  #   Vector2d(2, 3).y # => 3
  #
  # @return [Integer, Float, Rational, BigDecimal]
  attr_reader :x, :y

  # Creates a vector from two coordinates, which must be real numbers.
  # Every vector is constructed through here, so this is what keeps a
  # coordinate from being anything else. Instances are frozen.
  #
  #   Vector2d.new(2, 3)                    # => Vector2d(2,3)
  #   Vector2d.new(Complex(1, 2), 3)        # => ArgumentError
  #   Vector2d.new(2, 3).frozen?            # => true
  #   Ractor.shareable?(Vector2d.new(2, 3)) # => true
  #
  # @param x [Integer, Float, Rational, BigDecimal] the x coordinate
  # @param y [Integer, Float, Rational, BigDecimal] the y coordinate
  def initialize(x, y)
    @x = coordinate(x)
    @y = coordinate(y)
    freeze
  end

  # Copies are frozen too.
  #
  #   Vector2d(2, 3).dup.frozen? # => true
  #
  # @param other [Vector2d] the vector being copied
  # @return [void]
  def initialize_copy(other)
    super
    freeze
  end

  # Compares two vectors
  #
  #   Vector2d(2, 3) == Vector2d(2, 3) # => true
  #   Vector2d(2, 3) == Vector2d(1, 0) # => false
  #   Vector2d(2, 3) == [2, 3]         # => false
  #
  # @param other [Object] any object
  # @return [Boolean]
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
  # @param other [Object] any object
  # @return [Boolean]
  def eql?(other)
    other.instance_of?(self.class) && x.eql?(other.x) && y.eql?(other.y)
  end

  # Hash value of the vector, consistent with #eql?.
  #
  #   Vector2d(2, 3).hash == Vector2d(2, 3).hash # => true
  #
  # @return [Integer]
  def hash
    [self.class, x, y].hash
  end

  # Builds a new vector of this class from two coordinates. Every method
  # that returns a new vector goes through here, so a subclass whose
  # constructor takes more than the coordinates only has to override
  # this to have its own state carried across operations.
  #
  #   class Labeled < Vector2d
  #     attr_reader :label
  #
  #     def initialize(x, y, label = nil)
  #       @label = label
  #       super(x, y)
  #     end
  #
  #     def build(x, y) = self.class.new(x, y, label)
  #   end
  #
  #   Labeled.new(2, 3, "point").abs.label # => "point"
  #
  # Class level constructors have no instance to carry state from, and
  # use .build instead.
  #
  # @param x [Integer, Float, Rational, BigDecimal] the x coordinate
  # @param y [Integer, Float, Rational, BigDecimal] the y coordinate
  # @return [self]
  def build(x, y)
    self.class.build(x, y)
  end
end

# Shorthand for Vector2d.parse, and takes the same arguments.
#
#   Vector2d(2, 3)    # => Vector2d(2,3)
#   Vector2d("2x3")   # => Vector2d(2,3)
#   Vector2d([2, 3])  # => Vector2d(2,3)
#
# @return [Vector2d]
# @see Vector2d.parse for the arguments
def Vector2d(*)
  Vector2d.parse(*)
end
