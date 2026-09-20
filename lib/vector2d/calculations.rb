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

    # Returns the vector reversed.
    #
    #   -Vector2d(2, 3) # => Vector2d(-2,-3)
    #
    def -@
      reverse
    end

    # Returns the vector unchanged.
    #
    #   +Vector2d(2, 3) # => Vector2d(2,3)
    #
    def +@
      self
    end

    # Calculates the distance between two vectors.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(3, 4)
    #   v1.distance(v2) # => 1.4142..
    #
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
    def distance_squared(other)
      (self - other).length_squared
    end
    alias squared_distance distance_squared

    # Calculates the Manhattan distance between two vectors, the sum of
    # the absolute differences along each axis.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(5, 7)
    #   v1.manhattan_distance(v2) # => 7
    #
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
    def chebyshev_distance(other)
      (self - other).abs.to_a.max
    end

    # Linearly interpolates between this vector and another vector.
    #
    #   v1 = Vector2d(0, 0)
    #   v2 = Vector2d(10, 20)
    #   v1.lerp(v2, 0.0)  # => Vector2d(0.0,0.0)
    #   v1.lerp(v2, 0.25) # => Vector2d(2.5,5.0)
    #   v1.lerp(v2, 1.0)  # => Vector2d(10.0,20.0)
    #
    # The amount is not clamped to 0..1. Values outside that range
    # extrapolate past the end points.
    #
    #   v1.lerp(v2, 2.0)  # => Vector2d(20.0,40.0)
    #   v1.lerp(v2, -0.5) # => Vector2d(-5.0,-10.0)
    #
    def lerp(other, amount)
      v = coerce_vector(other)
      self + ((v - self) * amount)
    end

    # Returns the point halfway between this vector and another vector.
    #
    #   v1 = Vector2d(0, 0)
    #   v2 = Vector2d(10, 20)
    #   v1.midpoint(v2) # => Vector2d(5.0,10.0)
    #
    def midpoint(other)
      lerp(other, 0.5)
    end

    # Dot product of this vector and another vector.
    #
    #   v1 = Vector2d(2, 1)
    #   v2 = Vector2d(2, 3)
    #   v1.dot_product(v2) # => 7
    #
    def dot_product(other)
      v = coerce_vector(other)
      self.class.dot_product(self, v)
    end

    # Cross product of this vector and another vector.
    #
    #   v1 = Vector2d(2, 1)
    #   v2 = Vector2d(2, 3)
    #   v1.cross_product(v2) # => 4
    #
    def cross_product(other)
      v = coerce_vector(other)
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
      v = coerce_vector(other)
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

    # Vector projection of this vector onto another vector. The
    # argument is coerced, so scalars work too.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(4, 0)
    #   v1.project(v2) # => Vector2d(2.0,0.0)
    #
    # The zero vector has no direction, and there is nothing to project
    # onto. The zero vector is returned.
    #
    #   v1.project(Vector2d(0, 0)) # => Vector2d(0.0,0.0)
    #
    def project(other)
      v = coerce_vector(other)
      return build(0.0, 0.0) if v.zero?

      scale = dot_product(v).to_f / v.length_squared
      build(v.x * scale, v.y * scale)
    end

    # Vector rejection of this vector from another vector, the component
    # left over when the projection is subtracted.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(4, 0)
    #   v1.reject(v2) # => Vector2d(0.0,3.0)
    #
    # The zero vector has no direction, and nothing is projected away.
    #
    #   v1.reject(Vector2d(0, 0)) # => Vector2d(2.0,3.0)
    #
    def reject(other)
      self - project(other)
    end

    # Scalar projection of this vector onto another vector, the signed
    # length of the projection. It is negative when the vectors point in
    # opposite directions.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(4, 0)
    #   v1.scalar_projection(v2)              # => 2.0
    #   v1.scalar_projection(Vector2d(-4, 0)) # => -2.0
    #
    # The zero vector has no direction, and there is nothing to project
    # onto. The scalar projection is zero.
    #
    #   v1.scalar_projection(Vector2d(0, 0)) # => 0.0
    #
    def scalar_projection(other)
      v = coerce_vector(other)
      return 0.0 if v.zero?

      dot_product(v) / v.length
    end

    # Reflects this vector about the line perpendicular to the normal,
    # the way a ray bounces off a surface. The normal is normalized
    # internally, so it can be of any length.
    #
    #   vector = Vector2d(2, 3)
    #   vector.reflect(Vector2d(0, 1)) # => Vector2d(2.0,-3.0)
    #   vector.reflect(Vector2d(0, 5)) # => Vector2d(2.0,-3.0)
    #
    # The zero vector has no direction, and defines no surface to
    # reflect off. Nothing is reflected, and the vector is returned.
    #
    #   vector.reflect(Vector2d(0, 0)) # => Vector2d(2.0,3.0)
    #
    def reflect(normal)
      v = coerce_vector(normal)
      return to_f_vector if v.zero?

      n = v.normalize
      self - (n * (2 * dot_product(n)))
    end

    private

    def calculate_each(method, other)
      v = coerce_vector(other)
      build(
        x.send(method, v.x),
        y.send(method, v.y)
      )
    end
  end
end
