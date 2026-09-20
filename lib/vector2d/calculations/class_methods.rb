# frozen_string_literal: true

class Vector2d
  module Calculations
    module ClassMethods
      # Calculates cross product of two vectors.
      #
      #   v1 = Vector2d(2, 1)
      #   v2 = Vector2d(2, 3)
      #   Vector2d.cross_product(v1, v2) # => 4
      #
      def cross_product(vector1, vector2)
        (vector1.x * vector2.y) - (vector1.y * vector2.x)
      end

      # Calculates dot product of two vectors.
      #
      #   v1 = Vector2d(2, 1)
      #   v2 = Vector2d(2, 3)
      #   Vector2d.dot_product(v1, v2) # => 7
      #
      def dot_product(vector1, vector2)
        (vector1.x * vector2.x) + (vector1.y * vector2.y)
      end

      # Calculates the signed angle in radians from the first vector to
      # the second, in the range -PI..PI. The angle is positive when the
      # second vector is counterclockwise from the first, and reversing
      # the arguments flips its sign.
      #
      #   v1 = Vector2d(2, 3)
      #   v2 = Vector2d(4, 5)
      #   Vector2d.angle_to(v1, v2) # => -0.0867..
      #   Vector2d.angle_to(v2, v1) # => 0.0867..
      #
      # Only the directions matter, not the magnitudes. The zero vector
      # has no direction, and the angle to or from it is zero.
      #
      #   Vector2d.angle_to(v1, Vector2d(0, 0)) # => 0.0
      #
      def angle_to(vector1, vector2)
        Math.atan2(cross_product(vector1, vector2),
                   dot_product(vector1, vector2))
      end

      # Calculates the unsigned angle between two vectors in radians, in
      # the range 0..PI. This is the magnitude of .angle_to, so the
      # order of the arguments does not matter.
      #
      #   v1 = Vector2d(2, 3)
      #   v2 = Vector2d(4, 5)
      #   Vector2d.angle_between(v1, v2) # => 0.0867..
      #   Vector2d.angle_between(v2, v1) # => 0.0867..
      #
      # Only the directions matter, not the magnitudes. The zero vector
      # has no direction, and the angle between it and anything is zero.
      #
      #   Vector2d.angle_between(v1, Vector2d(0, 0)) # => 0.0
      #
      def angle_between(vector1, vector2)
        angle_to(vector1, vector2).abs
      end
    end
  end
end
