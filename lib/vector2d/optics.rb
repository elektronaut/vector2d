# frozen_string_literal: true

class Vector2d
  # Reflection and refraction against a surface given by its normal.
  module Optics
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
