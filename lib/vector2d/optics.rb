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
  end
end
