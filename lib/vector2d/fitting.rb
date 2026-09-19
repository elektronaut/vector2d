# frozen_string_literal: true

class Vector2d
  module Fitting
    # Scales down the given vector unless it fits inside.
    #
    #   vector = Vector2d(20, 20)
    #   vector.contain(Vector2d(10, 10)) # => Vector2d(10,10)
    #   vector.contain(Vector2d(40, 20)) # => Vector2d(20,10)
    #   vector.contain(Vector2d(20, 40)) # => Vector2d(10,20)
    #
    def contain(other)
      v, = coerce(other)
      v.x > x || v.y > y ? v.fit_vector(self) : v
    end

    # Scales the vector to fit inside another vector, retaining the
    # aspect ratio.
    #
    #   vector = Vector2d(20, 10)
    #   vector.fit(Vector2d(10, 10)) # => Vector2d(10,5)
    #   vector.fit(Vector2d(20, 20)) # => Vector2d(20,10)
    #   vector.fit(Vector2d(40, 40)) # => Vector2d(40,20)
    #
    # Note: Either axis will be disregarded if zero or nil. This is a
    # feature, not a bug.
    #
    def fit(other)
      v, = coerce(other)
      fit_vector(v)
    end
    alias constrain_both fit

    # Constrain/expand so that one of the coordinates fit within (the
    # square implied by) another vector.
    #
    #   constraint = Vector2d(5, 5)
    #   Vector2d(20, 10).fit_either(constraint) # => Vector2d(10,5)
    #   Vector2d(10, 20).fit_either(constraint) # => Vector2d(5,10)
    #
    def fit_either(other)
      v, = coerce(other)
      scale = v.to_f_vector / self
      if scale.x.positive? && scale.y.positive?
        self * [scale.x, scale.y].max
      else
        fit_vector(v)
      end
    end
    alias constrain_one fit_either

    protected

    # Scales the vector to fit inside an already coerced vector.
    def fit_vector(other)
      scale = other.to_f_vector / self
      self * (
        if scale.y.zero? || (scale.x.positive? && scale.x < scale.y)
          scale.x
        else
          scale.y
        end
      )
    end
  end
end
