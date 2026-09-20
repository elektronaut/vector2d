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

    # Length of vector.
    #
    #   Vector2d(2, 3).length # => 3.6055..
    #
    def length
      Math.sqrt(length_squared)
    end

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
