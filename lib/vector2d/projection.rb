# frozen_string_literal: true

class Vector2d
  # Products of two vectors, and the projection, reflection and
  # refraction built on them.
  module Projection
    module ClassMethods
      # Calculates dot product of two vectors.
      #
      #   v1 = Vector2d(2, 1)
      #   v2 = Vector2d(2, 3)
      #   Vector2d.dot_product(v1, v2) # => 7
      #
      def dot_product(vector1, vector2)
        (vector1.x * vector2.x) + (vector1.y * vector2.y)
      end

      # Calculates cross product of two vectors.
      #
      #   v1 = Vector2d(2, 1)
      #   v2 = Vector2d(2, 3)
      #   Vector2d.cross_product(v1, v2) # => 4
      #
      def cross_product(vector1, vector2)
        (vector1.x * vector2.y) - (vector1.y * vector2.x)
      end
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

    # Refracts this vector through a surface with the given normal and
    # ratio of refractive indices, the way a ray bends entering a
    # different medium. The normal is normalized internally, so it can
    # be of any length.
    #
    #   ray = Vector2d(1, -1).normalize
    #   ray.refract(Vector2d(0, 1), 0.5) # => Vector2d(0.3535..,-0.9354..)
    #   ray.refract(Vector2d(0, 5), 0.5) # => Vector2d(0.3535..,-0.9354..)
    #
    # A ratio of one leaves the ray on its course.
    #
    #   ray.refract(Vector2d(0, 1), 1.0) # => Vector2d(0.7071..,-0.7071..)
    #
    # Past the critical angle the ray does not cross the surface at all.
    # This is total internal reflection, and the zero vector is
    # returned.
    #
    #   ray.refract(Vector2d(0, 1), 2.0) # => Vector2d(0.0,0.0)
    #
    # The zero vector has no direction, and defines no surface to
    # refract through. Nothing is refracted, and the vector is returned.
    #
    #   ray.refract(Vector2d(0, 0), 0.5) # => Vector2d(0.7071..,-0.7071..)
    #
    # Raises ArgumentError unless the ratio is a real number.
    #
    #   ray.refract(Vector2d(0, 1), Complex(1, 2)) # => ArgumentError
    #
    def refract(normal, refractive_index)
      v = coerce_vector(normal)
      eta = coordinate(refractive_index)
      return to_f_vector if v.zero?

      refract_through(v.normalize, eta)
    end

    private

    # Refracts through a normalized normal. A negative discriminant is
    # total internal reflection, where no refracted ray exists.
    def refract_through(normal, eta)
      cosine = dot_product(normal)
      k = 1 - ((eta * eta) * (1 - (cosine * cosine)))
      return build(0.0, 0.0) if k.negative?

      (self * eta) - (normal * ((eta * cosine) + Math.sqrt(k)))
    end
  end
end
