# encoding: utf-8

class Vector2d
  module Fitting
    # Returns a new vector fitting inside another vector, retaining the aspect ratio.
    #
    # Examples:
    #
    #   vector = Vector2d.new(20, 10)
    #   vector.fit(Vector2d.new(10, 10)) # => Vector2d(10, 5)
    #   vector.fit(Vector2d.new(20, 20)) # => Vector2d(20, 10)
    #   vector.fit(Vector2d.new(40, 40)) # => Vector2d(40, 20)
    #
    # Note: Either axis will be disregarded if zero or nil. This is a feature, not a bug. ;)
    #
    def fit(other)
      v, _ = coerce(other)
      scale = v.to_f / self
      self * ((scale.y == 0 || (scale.x > 0 && scale.x < scale.y)) ? scale.x : scale.y)
    end
    alias_method :constrain_both, :fit

    # Constrain/expand so that one of the coordinates fit within (the square implied by) another vector.
    #
    # Examples:
    #
    #   constraint = Vector2d.new(5, 5)
    #   Vector2d.new(20, 10).fit(constraint) # => Vector2d(10, 5)
    #   Vector2d.new(10, 20).fit(constraint) # => Vector2d(5, 10)
    #
    def fit_one(other)
      v, _ = coerce(other)
      scale = v.to_f / self
      if (scale.x > 0 && scale.y > 0)
        scale = (scale.x < scale.y) ? scale.y : scale.x
        self * scale
      else
        constrain_both(v)
      end
    end
    alias_method :constrain_one, :fit_one
  end
end