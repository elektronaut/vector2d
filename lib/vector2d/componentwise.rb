# frozen_string_literal: true

class Vector2d
  # Operations applied to each coordinate on its own, the way Numeric
  # applies them to a number.
  module Componentwise
    # Returns the absolute value of each axis. This is component-wise,
    # not the magnitude of the vector, which is #length.
    #
    #   Vector2d(-2, 3).abs  # => Vector2d(2,3)
    #   Vector2d(-2, -3).abs # => Vector2d(2,3)
    #
    # @return [self]
    def abs
      build(x.abs, y.abs)
    end

    # Rounds vector up to nearest integer.
    #
    #   Vector2d(2.4, 3.6).ceil        # => Vector2d(3,4)
    #   Vector2d(2.441, 3.666).ceil(2) # => Vector2d(2.45,3.67)
    #
    # @param digits [Integer] the number of decimal places to keep
    # @return [self]
    def ceil(digits = 0)
      build(x.ceil(digits), y.ceil(digits))
    end

    # Rounds vector down to nearest integer.
    #
    #   Vector2d(2.4, 3.6).floor        # => Vector2d(2,3)
    #   Vector2d(2.444, 3.669).floor(2) # => Vector2d(2.44,3.66)
    #
    # @param digits [Integer] the number of decimal places to keep
    # @return [self]
    def floor(digits = 0)
      build(x.floor(digits), y.floor(digits))
    end

    # Rounds vector to nearest integer.
    #
    #   Vector2d(2.4, 3.6).round         # => Vector2d(2,4)
    #   Vector2d(2.4444, 3.666).round(2) # => Vector2d(2.44,3.67)
    #
    # @param digits [Integer] the number of decimal places to keep
    # @return [self]
    def round(digits = 0)
      build(x.round(digits), y.round(digits))
    end

    # @deprecated Use #limit_length instead. The name belongs to the
    # #ceil/#floor/#round family, which maps Numeric over both
    # coordinates.
    #
    # @param max [Integer, Float, Rational, BigDecimal] the maximum length
    # @return [self]
    def truncate(max)
      warn_deprecated("Vector2d#truncate is deprecated. Use #limit_length instead.")
      limit_length(max)
    end

    # Returns the sign of each axis, -1, 0 or 1.
    #
    #   Vector2d(-2, 3).sign # => Vector2d(-1,1)
    #   Vector2d(0, -3).sign # => Vector2d(0,-1)
    #
    # The signs are integers, whatever the coordinates were. There are
    # only three of them, and they are exact.
    #
    #   Vector2d(-2.5, 0.0).sign # => Vector2d(-1,0)
    #
    # NaN has no sign, so ArgumentError is raised.
    #
    #   Vector2d(Float::NAN, 3).sign # => ArgumentError
    #
    # @return [self] a vector of -1, 0 and 1
    def sign
      build(coordinate_sign(x), coordinate_sign(y))
    end

    # Snaps each axis to the nearest multiple of a step. The step is
    # coerced, so scalars work too, and a vector gives each axis its
    # own step.
    #
    #   vector = Vector2d(23, 47)
    #   vector.snap(10)              # => Vector2d(20,50)
    #   vector.snap(Vector2d(10, 5)) # => Vector2d(20,45)
    #
    # Coordinates take the type of the step, so an integer step snaps
    # to integers.
    #
    #   Vector2d(2.3, 3.7).snap(1)   # => Vector2d(2,4)
    #   Vector2d(2.3, 3.7).snap(0.5) # => Vector2d(2.5,3.5)
    #
    # A step of zero has no multiples to snap to, and leaves the axis
    # unchanged.
    #
    #   vector.snap(0)               # => Vector2d(23,47)
    #   vector.snap(Vector2d(10, 0)) # => Vector2d(20,47)
    #
    # @!macro coercible
    # @return [self]
    def snap(step)
      v = coerce_vector(step)
      build(snap_coordinate(x, v.x), snap_coordinate(y, v.y))
    end

    # Returns the larger value of each axis. The other vector is
    # coerced, so scalars work too.
    #
    #   vector = Vector2d(2, 8)
    #   vector.max(Vector2d(5, 5)) # => Vector2d(5,8)
    #   vector.max(5)              # => Vector2d(5,8)
    #
    # @!macro coercible
    # @return [self]
    def max(other)
      v = coerce_vector(other)
      build([x, v.x].max, [y, v.y].max)
    end

    # Returns the smaller value of each axis. The other vector is
    # coerced, so scalars work too.
    #
    #   vector = Vector2d(2, 8)
    #   vector.min(Vector2d(5, 5)) # => Vector2d(2,5)
    #   vector.min(5)              # => Vector2d(2,5)
    #
    # @!macro coercible
    # @return [self]
    def min(other)
      v = coerce_vector(other)
      build([x, v.x].min, [y, v.y].min)
    end

    # Clamps the vector between two others, one axis at a time. The
    # bounds are coerced, so scalars work too.
    #
    #   vector = Vector2d(2, 8)
    #   vector.clamp(Vector2d(3, 3), Vector2d(6, 6)) # => Vector2d(3,6)
    #   vector.clamp(3, 6)                           # => Vector2d(3,6)
    #
    # The bounds can also be given as a single range, which may be
    # beginless or endless to clamp only one side.
    #
    #   vector.clamp(3..6) # => Vector2d(3,6)
    #   vector.clamp(..6)  # => Vector2d(2,6)
    #   vector.clamp(3..)  # => Vector2d(3,8)
    #
    # The range must not exclude its end, as with Comparable#clamp.
    #
    #   vector.clamp(3...6) # => ArgumentError
    #
    # @overload clamp(min, max)
    #   @param min [Vector2d, Array, String, Hash, Integer, Float, Rational,
    #     BigDecimal, ::Vector, ::Matrix] the lower bound, anything
    #     Vector2d.parse accepts
    #   @param max [Vector2d, Array, String, Hash, Integer, Float, Rational,
    #     BigDecimal, ::Vector, ::Matrix] the upper bound
    # @overload clamp(range)
    #   @param range [Range] both bounds, and may be beginless or endless
    # @return [self]
    def clamp(min, max = nil)
      min_v, max_v = clamp_bounds(min, max)
      build(
        x.clamp(Range.new(min_v&.x, max_v&.x)),
        y.clamp(Range.new(min_v&.y, max_v&.y))
      )
    end

    # Returns the vector with x replaced.
    #
    #   Vector2d(2, 3).with_x(5) # => Vector2d(5,3)
    #
    # Vectors are immutable, so this is how a single axis is changed.
    # The value is a coordinate, not a vector, and is not coerced.
    #
    #   Vector2d(2, 3).with_x("5") # => ArgumentError
    #
    # @param value [Integer, Float, Rational, BigDecimal] the new x coordinate
    # @return [self]
    def with_x(value)
      build(value, y)
    end

    # Returns the vector with y replaced.
    #
    #   Vector2d(2, 3).with_y(5) # => Vector2d(2,5)
    #
    # The value is a coordinate, not a vector, and is not coerced.
    #
    #   Vector2d(2, 3).with_y(nil) # => ArgumentError
    #
    # @param value [Integer, Float, Rational, BigDecimal] the new y coordinate
    # @return [self]
    def with_y(value)
      build(x, value)
    end

    private

    def clamp_bounds(min, max)
      if min.is_a?(Range)
        return range_bounds(min, max)
               .map { |bound| bound && coerce_vector(bound) }
      end

      raise ArgumentError, "wrong number of arguments (given 1, expected 2)" if max.nil?

      [coerce_vector(min), coerce_vector(max)]
    end

    # Splits the range form of #clamp and #clamp_length into its two
    # ends, either of which can be nil.
    def range_bounds(range, max)
      raise ArgumentError, "wrong number of arguments (given 2, expected 1)" unless max.nil?
      raise ArgumentError, "cannot clamp with an exclusive range" if range.exclude_end?

      [range.begin, range.end]
    end

    # The sign of a coordinate. Comparing to zero gives one of -1, 0
    # and 1, or nothing at all for NaN.
    def coordinate_sign(value)
      sign = value <=> 0
      raise ArgumentError, "NaN has no sign" if sign.nil?

      sign
    end

    # Rounds a coordinate to the nearest multiple of a step. A step of
    # zero has no multiples, and the coordinate is left alone.
    def snap_coordinate(value, step)
      return value if step.zero?

      (value / step.to_f).round * step
    end
  end
end
