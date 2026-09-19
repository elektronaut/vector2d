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
    #   Vector2d(2, 3).aspect_ratio # => 0.6667..
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
      (length - 1.0).abs < (4 * Float::EPSILON)
    end
  end
end
