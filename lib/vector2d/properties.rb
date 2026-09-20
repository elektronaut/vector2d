# frozen_string_literal: true

class Vector2d
  module Properties
    # Angle of vector.
    #
    #   Vector2d(2, 3).angle # => 0.9827..
    #
    def angle
      Math.atan2(y, x)
    end

    # Area covered by the vector, the product of its coordinates.
    # Coordinates are taken by magnitude, as in #aspect_ratio, so the
    # area is never negative.
    #
    #   Vector2d(2, 3).area  # => 6
    #   Vector2d(-2, 3).area # => 6
    #
    # A vector without width or height covers nothing.
    #
    #   Vector2d(2, 0).area # => 0
    #
    def area
      (x * y).abs
    end

    # Aspect ratio of vector.
    #
    #   Vector2d(2, 3).aspect_ratio # => 0.6666..
    #
    # A vector without height has no aspect ratio, so ArgumentError is
    # raised.
    #
    #   Vector2d(2, 0).aspect_ratio # => ArgumentError
    #   Vector2d(0, 0).aspect_ratio # => ArgumentError
    #
    def aspect_ratio
      raise ArgumentError, "the zero vector has no aspect ratio" if zero?
      raise ArgumentError, "#{inspect} has no aspect ratio, y is zero" if y.zero?

      (x.to_f / y).abs
    end

    # Is the vector wider than it is tall?
    #
    #   Vector2d(3, 2).landscape? # => true
    #   Vector2d(2, 3).landscape? # => false
    #   Vector2d(2, 2).landscape? # => false
    #
    # Coordinates are compared by magnitude, as in #aspect_ratio.
    #
    #   Vector2d(-3, 2).landscape? # => true
    #
    def landscape?
      x.abs > y.abs
    end

    # Is the vector taller than it is wide?
    #
    #   Vector2d(2, 3).portrait? # => true
    #   Vector2d(3, 2).portrait? # => false
    #   Vector2d(2, 2).portrait? # => false
    #
    # Coordinates are compared by magnitude, as in #aspect_ratio.
    #
    #   Vector2d(2, -3).portrait? # => true
    #
    def portrait?
      x.abs < y.abs
    end

    # Is the vector as wide as it is tall?
    #
    #   Vector2d(2, 2).square? # => true
    #   Vector2d(2, 3).square? # => false
    #
    # Coordinates are compared by magnitude, as in #aspect_ratio.
    # Exactly one of #square?, #landscape? and #portrait? holds for any
    # vector.
    #
    #   Vector2d(-2, 2).square? # => true
    #
    # Unlike #aspect_ratio, these three don't single out the zero
    # vector. It is square.
    #
    #   Vector2d(0, 0).square? # => true
    #
    def square?
      x.abs == y.abs
    end

    # Length of vector.
    #
    #   Vector2d(2, 3).length # => 3.6055..
    #
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
    def length_squared
      (x * x) + (y * y)
    end
    alias squared_length length_squared

    # Is this the zero vector?
    #
    #   Vector2d(0, 0).zero? # => true
    #   Vector2d(2, 3).zero? # => false
    #
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
    def approx_zero?(tolerance = nil)
      return length <= coordinate(tolerance) unless tolerance.nil?

      near_zero?(length)
    end

    # Are the two vectors equal, give or take floating point drift?
    # Arithmetic that should land on a given vector usually lands a few
    # ulps off it instead, which #== reports as a difference.
    #
    #   v1 = Vector2d(0.1, 0.2) + Vector2d(0.2, 0.4)
    #   v2 = Vector2d(0.3, 0.6)
    #   v1                   # => Vector2d(0.30000000000000004,0.6000..)
    #   v1 == v2             # => false
    #   v1.approx_equal?(v2) # => true
    #
    # The other vector is coerced, unlike in #==, so anything .parse
    # accepts is compared as a vector.
    #
    #   v1.approx_equal?([0.3, 0.6]) # => true
    #   v1 == [0.3, 0.6]             # => false
    #
    # The default tolerance is the one #parallel? and #perpendicular_to?
    # use, a few ulps scaled by the magnitude of the vectors, so the
    # same amount of drift is absorbed whatever the coordinates are
    # sized like. It covers rounding error, and nothing more.
    #
    #   big = Vector2d(1e8, 2e8)
    #   big.approx_equal?(big.rotate(2 * Math::PI)) # => true
    #   big.approx_equal?(Vector2d(1e8, 2.1e8))     # => false
    #
    # Pass a tolerance for anything looser. It is an absolute distance
    # between the two vectors, and is not scaled.
    #
    #   v3 = Vector2d(2, 3)
    #   v3.approx_equal?(Vector2d(2, 4), 1.5) # => true
    #   v3.approx_equal?(Vector2d(2, 4), 0.5) # => false
    #
    # Note that this is not a replacement for #==. Approximate equality
    # is not transitive, and vectors that are approximately equal do not
    # have the same #hash.
    #
    def approx_equal?(other, tolerance = nil)
      v = coerce_vector(other)
      return distance(v) <= coordinate(tolerance) unless tolerance.nil?

      near_zero?(distance(v), [1.0, length, v.length].max)
    end

    # Are both coordinates finite?
    #
    #   Vector2d(2, 3).finite?               # => true
    #   Vector2d(2, Float::INFINITY).finite? # => false
    #   Vector2d(2, Float::NAN).finite?      # => false
    #
    def finite?
      x.finite? && y.finite?
    end

    # Is either coordinate NaN? Nothing else in the library produces
    # one, but arithmetic on infinities does.
    #
    #   Vector2d(2, 3).nan?          # => false
    #   Vector2d(2, Float::NAN).nan? # => true
    #
    #   (Vector2d(2, 3) * Float::INFINITY * 0).nan? # => true
    #
    def nan?
      coordinate_nan?(x) || coordinate_nan?(y)
    end

    # Is this a normalized vector?
    #
    #   Vector2d(0, 1).normalized? # => true
    #   Vector2d(2, 3).normalized? # => false
    #
    def normalized?
      near_zero?(length - 1.0)
    end

    # Are the two vectors parallel? Vectors pointing in opposite
    # directions are parallel too.
    #
    #   v = Vector2d(2, 3)
    #   v.parallel?(Vector2d(4, 6))   # => true
    #   v.parallel?(Vector2d(-4, -6)) # => true
    #   v.parallel?(Vector2d(3, 2))   # => false
    #
    # Only the directions matter, not the magnitudes. The zero vector
    # has no direction, and is parallel to everything.
    #
    #   v.parallel?(Vector2d(0, 0)) # => true
    #
    def parallel?(other)
      v = coerce_vector(other)
      return true if zero? || v.zero?

      near_zero?(cross_product(v), length * v.length)
    end

    # Are the two vectors linearly independent? This is the inverse of
    # #parallel?, and matches Vector#independent? in the standard
    # library.
    #
    #   v = Vector2d(2, 3)
    #   v.independent?(Vector2d(3, 2))   # => true
    #   v.independent?(Vector2d(4, 6))   # => false
    #   v.independent?(Vector2d(-4, -6)) # => false
    #
    # The zero vector is parallel to everything, so nothing is
    # independent of it.
    #
    #   v.independent?(Vector2d(0, 0)) # => false
    #
    def independent?(other)
      !parallel?(other)
    end

    # Do the two vectors point in opposite directions? Only the
    # directions matter, not the magnitudes.
    #
    #   v = Vector2d(2, 3)
    #   v.opposite?(Vector2d(-2, -3)) # => true
    #   v.opposite?(Vector2d(-4, -6)) # => true
    #   v.opposite?(Vector2d(4, 6))   # => false
    #   v.opposite?(Vector2d(3, 2))   # => false
    #
    # Opposite vectors are parallel, but #parallel? does not care which
    # way along the line the other vector points.
    #
    #   v.parallel?(Vector2d(-4, -6)) # => true
    #
    # The zero vector has no direction to be the opposite of, so unlike
    # #parallel? and #perpendicular_to?, which it satisfies trivially,
    # it is opposite to nothing.
    #
    #   v.opposite?(Vector2d(0, 0)) # => false
    #
    def opposite?(other)
      v = coerce_vector(other)
      return false if zero? || v.zero?

      parallel?(v) && dot_product(v).negative?
    end

    # Are the two vectors perpendicular to each other?
    #
    #   v = Vector2d(2, 3)
    #   v.perpendicular_to?(Vector2d(-3, 2)) # => true
    #   v.perpendicular_to?(Vector2d(3, 2))  # => false
    #
    # Only the directions matter, not the magnitudes. The zero vector
    # has no direction, and is perpendicular to everything.
    #
    #   v.perpendicular_to?(Vector2d(0, 0)) # => true
    #
    def perpendicular_to?(other)
      v = coerce_vector(other)
      return true if zero? || v.zero?

      near_zero?(dot_product(v), length * v.length)
    end

    # Polar coordinates of vector, as a [length, angle] array.
    #
    #   Vector2d(2, 3).to_polar # => [3.6055.., 0.9827..]
    #
    # Vector2d.from_angle takes the same pair back.
    #
    #   length, angle = Vector2d(2, 3).to_polar
    #   Vector2d.from_angle(angle, length) # => Vector2d(2.0,3.0)
    #
    def to_polar
      [length, angle]
    end

    private

    # Is the coordinate NaN? Only floats and decimals can be, the rest
    # of Numeric has no answer to give.
    def coordinate_nan?(value)
      value.respond_to?(:nan?) && value.nan?
    end

    # Is a value close enough to zero to count as zero? The tolerance
    # scales with the magnitudes the value was calculated from.
    #
    #   near_zero?(1e-14)      # => false
    #   near_zero?(1e-14, 1e6) # => true
    #
    def near_zero?(value, scale = 1.0)
      value.abs < (4 * Float::EPSILON * scale)
    end
  end
end
