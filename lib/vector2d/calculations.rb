# frozen_string_literal: true

require_relative "calculations/class_methods"

class Vector2d
  module Calculations
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
    # Raises ArgumentError unless the amount is a real number. One
    # amount applies to both axes.
    #
    #   v1.lerp(v2, Vector2d(0.25, 0.5)) # => ArgumentError
    #
    def lerp(other, amount)
      v = coerce_vector(other)
      amount = coordinate(amount)
      build(interpolate(x, v.x, amount), interpolate(y, v.y, amount))
    end

    # Returns the amount #lerp would need to land on a value, the
    # position of that value along the segment from this vector to
    # another one. This is the inverse of #lerp.
    #
    #   v1 = Vector2d(0, 0)
    #   v2 = Vector2d(10, 20)
    #   v1.inverse_lerp(v2, Vector2d(2.5, 5.0)) # => 0.25
    #   v1.inverse_lerp(v2, v1)                 # => 0.0
    #   v1.inverse_lerp(v2, v2)                 # => 1.0
    #
    # The result is a scalar, one amount for both axes, matching the
    # single amount #lerp takes.
    #
    #   v1.lerp(v2, v1.inverse_lerp(v2, Vector2d(2.5, 5.0))) # => Vector2d(2.5,5.0)
    #
    # The value does not have to lie on the segment. Anything off it is
    # projected onto the line through the end points first, so the
    # result is the position of the nearest point on that line.
    #
    #   v1.inverse_lerp(v2, Vector2d(5, 0)) # => 0.1
    #
    # The result is not clamped to 0..1, the same way the amount #lerp
    # takes is not. Values beyond the end points fall outside it.
    #
    #   v1.inverse_lerp(v2, Vector2d(20, 40))  # => 2.0
    #   v1.inverse_lerp(v2, Vector2d(-5, -10)) # => -0.5
    #
    # A segment between two identical vectors has no length to measure
    # along, and no amount reaches anything but its own end point. Zero
    # is returned.
    #
    #   v1.inverse_lerp(v1, Vector2d(2.5, 5.0)) # => 0.0
    #
    def inverse_lerp(other, value)
      segment = coerce_vector(other) - self
      return 0.0 if segment.zero?

      (coerce_vector(value) - self).dot_product(segment).to_f / segment.length_squared
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
    alias inner_product dot_product
    alias dot dot_product

    # Cross product of this vector and another vector. In two
    # dimensions this is a scalar, the z component of the equivalent
    # three dimensional cross product. Vector#cross_product returns a
    # perpendicular vector instead, which is #perpendicular here.
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
    alias angle_with angle_between

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

    private

    def interpolate(start, finish, amount)
      start + ((finish - start) * amount)
    end

    # Is the value a number both coordinates can be combined with
    # directly? Complex is Numeric, but it is not a coordinate.
    def real_number?(value)
      value.is_a?(Numeric) && value.real?
    end

    def calculate_each(method, other)
      return build(x.send(method, other), y.send(method, other)) if real_number?(other)

      v = coerce_vector(other)
      build(
        x.send(method, v.x),
        y.send(method, v.y)
      )
    end
  end
end
