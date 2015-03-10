# encoding: utf-8

class Vector2d
  module Fitting
    include Contracts

    # Scales down the given vector unless it fits inside.
    #
    #   vector = Vector2d(20, 20)
    #   vector.contain(Vector2d(10, 10)) # => Vector2d(10,10)
    #   vector.contain(Vector2d(40, 20)) # => Vector2d(20,10)
    #   vector.contain(Vector2d(20, 40)) # => Vector2d(10,20)
    #
    Contract VectorLike => Vector2d
    def contain(other)
      v, _ = coerce(other)
      (v.x > x || v.y > y) ? other.fit(self) : other
    end

    # Scales the vector to fit inside another vector, retaining the aspect ratio.
    #
    #   vector = Vector2d(20, 10)
    #   vector.fit(Vector2d(10, 10)) # => Vector2d(10,5)
    #   vector.fit(Vector2d(20, 20)) # => Vector2d(20,10)
    #   vector.fit(Vector2d(40, 40)) # => Vector2d(40,20)
    #
    # Note: Either axis will be disregarded if zero or nil. This is a feature, not a bug.
    #
    Contract VectorLike => Vector2d
    def fit(other)
      v, _ = coerce(other)
      scale = v.to_f_vector / self
      self * ((scale.y == 0 || (scale.x > 0 && scale.x < scale.y)) ? scale.x : scale.y)
    end
    alias_method :constrain_both, :fit

    # Constrain/expand so that one of the coordinates fit within (the square implied by) another vector.
    #
    #   constraint = Vector2d(5, 5)
    #   Vector2d(20, 10).fit_either(constraint) # => Vector2d(10,5)
    #   Vector2d(10, 20).fit_either(constraint) # => Vector2d(5,10)
    #
    Contract VectorLike => Vector2d
    def fit_either(other)
      v, _ = coerce(other)
      scale = v.to_f_vector / self
      if (scale.x > 0 && scale.y > 0)
        scale = (scale.x < scale.y) ? scale.y : scale.x
        self * scale
      else
        fit(v)
      end
    end
    alias_method :constrain_one, :fit_either
  end
end
