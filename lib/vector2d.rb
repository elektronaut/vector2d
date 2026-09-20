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
require_relative "vector2d/parsing"
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
  extend Vector2d::Parsing
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
  def self.build(x, y)
    new(x, y)
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
