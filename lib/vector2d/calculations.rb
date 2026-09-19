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
      #   Vector2d.dot_product(v1, v2) # => 10
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

    # Multiplies vectors.
    #
    #   Vector2d(1, 2) * Vector2d(2, 3) # => Vector2d(2, 6)
    #   Vector2d(1, 2) * 2              # => Vector2d(2, 4)
    #
    def *(other)
      calculate_each(:*, other)
    end

    # Divides vectors.
    #
    #   Vector2d(4, 2) / Vector2d(2, 1) # => Vector2d(2, 2)
    #   Vector2d(4, 2) / 2              # => Vector2d(2, 1)
    #
    def /(other)
      calculate_each(:/, other)
    end

    # Adds vectors.
    #
    #   Vector2d(1, 2) + Vector2d(2, 3) # => Vector2d(3, 5)
    #   Vector2d(1, 2) + 2              # => Vector2d(3, 4)
    #
    def +(other)
      calculate_each(:+, other)
    end

    # Subtracts vectors.
    #
    #   Vector2d(2, 3) - Vector2d(2, 1) # => Vector2d(0, 2)
    #   Vector2d(4, 3) - 1              # => Vector2d(3, 2)
    #
    def -(other)
      calculate_each(:-, other)
    end

    # Calculates the distance between two vectors.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(3, 4)
    #   v1.distance(v2) # => 1.4142..
    #
    def distance(other)
      Math.sqrt(distance_squared(other))
    end

    # Calculate squared distance between vectors. Avoids the square root
    # when distances are only being compared to each other.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(5, 6)
    #   v1.distance_squared(v2) # => 18
    #
    def distance_squared(other)
      v = to_vector(other)
      dx = v.x - x
      dy = v.y - y
      (dx * dx) + (dy * dy)
    end
    alias squared_distance distance_squared

    # Dot product of this vector and another vector.
    #
    #   v1 = Vector2d(2, 1)
    #   v2 = Vector2d(2, 3)
    #   v1.dot_product(v2) # => 10
    #
    def dot_product(other)
      v = to_vector(other)
      self.class.dot_product(self, v)
    end

    # Cross product of this vector and another vector.
    #
    #   v1 = Vector2d(2, 1)
    #   v2 = Vector2d(2, 3)
    #   v1.cross_product(v2) # => 4
    #
    def cross_product(other)
      v = to_vector(other)
      self.class.cross_product(self, v)
    end

    # Signed angle in radians from this vector to another vector, in the
    # range -PI..PI. The angle is positive when the other vector is
    # counterclockwise from this one.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(4, 5)
    #   v1.angle_to(v2) # => -0.0867..
    #   v2.angle_to(v1) # => 0.0867..
    #
    # Only the directions matter, not the magnitudes. The zero vector
    # has no direction, and the angle to or from it is zero.
    #
    #   v1.angle_to(Vector2d(0, 0)) # => 0.0
    #
    def angle_to(other)
      v = to_vector(other)
      self.class.angle_to(self, v)
    end

    # Unsigned angle in radians between this vector and another vector,
    # in the range 0..PI. This is the magnitude of #angle_to, so it is
    # the same in either direction.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(4, 5)
    #   v1.angle_between(v2) # => 0.0867..
    #   v2.angle_between(v1) # => 0.0867..
    #
    # Only the directions matter, not the magnitudes. The zero vector
    # has no direction, and the angle between it and anything is zero.
    #
    #   v1.angle_between(Vector2d(0, 0)) # => 0.0
    #
    def angle_between(other)
      angle_to(other).abs
    end

    private

    def calculate_each(method, other)
      v = to_vector(other)
      self.class.new(
        x.send(method, v.x),
        y.send(method, v.y)
      )
    end
  end
end
