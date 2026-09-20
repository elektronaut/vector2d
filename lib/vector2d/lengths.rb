# frozen_string_literal: true

class Vector2d
  # The length of a vector, the distance between two, and the
  # operations that change the length while keeping the direction.
  module Lengths
    # Length of vector.
    #
    #   Vector2d(2, 3).length # => 3.6055..
    #
    # @return [Float]
    def length
      Math.sqrt(length_squared)
    end
    alias magnitude length
    alias norm length

    # Squared length of vector. Avoids the square root when lengths are
    # only being compared to each other.
    #
    #   Vector2d(2, 3).length_squared # => 13
    #
    # @return [Integer, Float, Rational, BigDecimal]
    def length_squared
      (x * x) + (y * y)
    end

    # @deprecated Use #length_squared instead.
    #
    # @return [Integer, Float, Rational, BigDecimal]
    def squared_length
      warn_deprecated("Vector2d#squared_length is deprecated. Use #length_squared instead.")
      length_squared
    end

    # Is this the zero vector?
    #
    #   Vector2d(0, 0).zero? # => true
    #   Vector2d(2, 3).zero? # => false
    #
    # @return [Boolean]
    def zero?
      length_squared.zero?
    end

    # Is this the zero vector, give or take floating point drift? See
    # #approx_equal? for what the tolerance is.
    #
    #   Vector2d(0, 0).approx_zero?     # => true
    #   Vector2d(1e-17, 0).approx_zero? # => true
    #   Vector2d(1e-15, 0).approx_zero? # => false
    #
    # An explicit tolerance is an absolute length.
    #
    #   Vector2d(0.2, 0).approx_zero?(0.5) # => true
    #
    # @param tolerance [Integer, Float, Rational, BigDecimal, nil]
    #   an absolute length, or nil for the default scaled tolerance
    # @return [Boolean]
    def approx_zero?(tolerance = nil)
      return length <= coordinate(tolerance) unless tolerance.nil?

      near_zero?(length)
    end

    # Is this a normalized vector?
    #
    #   Vector2d(0, 1).normalized? # => true
    #   Vector2d(2, 3).normalized? # => false
    #
    # @return [Boolean]
    def normalized?
      near_zero?(length - 1.0)
    end

    # Normalizes the vector.
    #
    #   vector = Vector2d(2, 3)
    #   vector.normalize        # => Vector2d(0.5547.., 0.8320..)
    #   vector.normalize.length # => 1.0
    #
    # The zero vector has no direction, and is returned unchanged.
    #
    #   Vector2d(0, 0).normalize # => Vector2d(0,0)
    #
    # @return [self]
    def normalize
      resize(1.0)
    end

    # Changes magnitude of vector.
    #
    #   Vector2d(2, 3).resize(1.0) # => Vector2d(0.5547.., 0.8320..)
    #
    # The zero vector has no direction, and is returned unchanged.
    #
    #   Vector2d(0, 0).resize(1.0) # => Vector2d(0,0)
    #
    # A negative length reverses the vector.
    #
    #   Vector2d(2, 3).resize(-1.0) # => Vector2d(-0.5547..,-0.8320..)
    #
    # @param new_length [Integer, Float, Rational, BigDecimal] the new length
    # @return [self]
    def resize(new_length)
      new_length = coordinate(new_length)
      return self if zero?

      self * (new_length / length)
    end

    # Clamps the length of the vector, scaling it down if it is longer
    # than max. A single argument is a maximum.
    #
    #   vector = Vector2d(2.0, 3.0)
    #   vector.clamp_length(5.0) # => Vector2d(2.0, 3.0)
    #   vector.clamp_length(1.0) # => Vector2d(0.5547.., 0.8320..)
    #
    # Given two, the length is clamped between them, scaling the vector
    # up if it is shorter than min.
    #
    #   vector.clamp_length(5.0, 10.0) # => Vector2d(2.7735.., 4.1602..)
    #   vector.clamp_length(1.0, 10.0) # => Vector2d(2.0, 3.0)
    #
    # The bounds can also be given as a single range, which may be
    # beginless or endless to clamp only one side, as in #clamp.
    #
    #   vector.clamp_length(5.0..10.0) # => Vector2d(2.7735.., 4.1602..)
    #   vector.clamp_length(..1.0)     # => Vector2d(0.5547.., 0.8320..)
    #   vector.clamp_length(5.0..)     # => Vector2d(2.7735.., 4.1602..)
    #
    # The range must not exclude its end, as with Comparable#clamp.
    #
    #   vector.clamp_length(5.0...10.0) # => ArgumentError
    #
    # The zero vector has no direction, and is returned unchanged. It
    # can't be scaled up to a minimum length.
    #
    #   Vector2d(0, 0).clamp_length(1.0)      # => Vector2d(0,0)
    #   Vector2d(0, 0).clamp_length(1.0, 2.0) # => Vector2d(0,0)
    #
    # Lengths can't be negative, and min can't exceed max.
    #
    #   Vector2d(2, 3).clamp_length(-1.0)     # => ArgumentError
    #   Vector2d(2, 3).clamp_length(4.0, 2.0) # => ArgumentError
    #
    # @overload clamp_length(max)
    #   @param max [Integer, Float, Rational, BigDecimal] the maximum length
    # @overload clamp_length(min, max)
    #   @param min [Integer, Float, Rational, BigDecimal] the minimum length
    #   @param max [Integer, Float, Rational, BigDecimal] the maximum length
    # @overload clamp_length(range)
    #   @param range [Range] both bounds, and may be beginless or endless
    # @return [self]
    def clamp_length(min, max = nil)
      min_length, max_length = clamp_length_bounds(min, max)
      resize(length.clamp(Range.new(min_length, max_length)))
    end

    # Calculates the distance between two vectors.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(3, 4)
    #   v1.distance(v2) # => 1.4142..
    #
    # @!macro coercible
    # @return [Float]
    def distance(other)
      (self - other).length
    end

    # Calculate squared distance between vectors. Avoids the square root
    # when distances are only being compared to each other.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(5, 6)
    #   v1.distance_squared(v2) # => 18
    #
    # @!macro coercible
    # @return [Integer, Float, Rational, BigDecimal]
    def distance_squared(other)
      (self - other).length_squared
    end

    # @deprecated Use #distance_squared instead.
    #
    # @!macro coercible
    # @return [Integer, Float, Rational, BigDecimal]
    def squared_distance(other)
      warn_deprecated("Vector2d#squared_distance is deprecated. Use #distance_squared instead.")
      distance_squared(other)
    end

    # Calculates the Manhattan distance between two vectors, the sum of
    # the absolute differences along each axis.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(5, 7)
    #   v1.manhattan_distance(v2) # => 7
    #
    # @!macro coercible
    # @return [Integer, Float, Rational, BigDecimal]
    def manhattan_distance(other)
      (self - other).abs.to_a.sum
    end

    # Calculates the Chebyshev distance between two vectors, the largest
    # absolute difference along any axis.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(5, 7)
    #   v1.chebyshev_distance(v2) # => 4
    #
    # @!macro coercible
    # @return [Integer, Float, Rational, BigDecimal]
    def chebyshev_distance(other)
      (self - other).abs.to_a.max
    end

    # Unit vector pointing from this vector to another vector, the
    # direction a step from here to there would take. The other vector
    # is coerced, so scalars work too.
    #
    #   v1 = Vector2d(2, 3)
    #   v1.direction_to(Vector2d(2, 6)) # => Vector2d(0.0,1.0)
    #   v1.direction_to(Vector2d(5, 7)) # => Vector2d(0.6000..,0.8)
    #
    # This is (other - self).normalize. #distance measures the same
    # step, and #move_toward takes it.
    #
    # There is no direction to where you already are. The zero vector
    # has no direction, and is returned.
    #
    #   v1.direction_to(v1) # => Vector2d(0,0)
    #
    # @!macro coercible
    # @return [self]
    def direction_to(other)
      v = coerce_vector(other)
      build(v.x - x, v.y - y).normalize
    end

    private

    # Splits the bounds of #clamp_length into a [min, max] pair, either
    # of which can be nil for a one sided clamp. A single argument is a
    # maximum, so a minimum on its own has to come from a range.
    def clamp_length_bounds(min, max)
      return range_length_bounds(min, max) if min.is_a?(Range)
      return [nil, length_bound(min, "max")] if max.nil?

      [length_bound(min, "min"), length_bound(max, "max")]
    end

    def range_length_bounds(range, max)
      range_bounds(range, max).zip(%w[min max]).map do |bound, name|
        bound && length_bound(bound, name)
      end
    end

    # Validates one end of a length clamp. Lengths are never negative.
    def length_bound(value, name)
      value = coordinate(value)
      raise ArgumentError, "negative #{name} length: #{value}" if value.negative?

      value
    end
  end
end
