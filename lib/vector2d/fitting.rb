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
    # Coordinates are compared by magnitude, so negative vectors are
    # scaled the same way and keep their direction.
    #
    #   vector.contain(Vector2d(-40, 20)) # => Vector2d(-20,10)
    #
    # An axis that is zero is unconstrained, as in #fit, so the zero
    # vector contains anything.
    #
    #   Vector2d(0, 0).contain(Vector2d(40, 20)) # => Vector2d(40,20)
    #
    def contain(other)
      v = to_vector(other)
      v.x.abs > x.abs || v.y.abs > y.abs ? v.fit_vector(self) : v
    end

    # Scales the vector to fit inside another vector, retaining the
    # aspect ratio.
    #
    #   vector = Vector2d(20, 10)
    #   vector.fit(Vector2d(10, 10)) # => Vector2d(10,5)
    #   vector.fit(Vector2d(20, 20)) # => Vector2d(20,10)
    #   vector.fit(Vector2d(40, 40)) # => Vector2d(40,20)
    #
    # The constraint applies to the magnitude of each coordinate, and
    # the vector keeps its direction.
    #
    #   Vector2d(-20, 10).fit(Vector2d(5, 5)) # => Vector2d(-5,2.5)
    #
    # Note: Either axis will be disregarded if zero or nil. This is a
    # feature, not a bug. A constraint that is zero on both axes leaves
    # the vector unchanged.
    #
    #   Vector2d(20, 10).fit(Vector2d(0, 0)) # => Vector2d(20,10)
    #
    # The zero vector has no direction, and is returned unchanged.
    #
    #   Vector2d(0, 0).fit(Vector2d(10, 10)) # => Vector2d(0,0)
    #
    def fit(other)
      return self if zero?

      v = to_vector(other)
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
    # Note: Either axis will be disregarded if zero or nil, as in #fit.
    # This is a feature, not a bug.
    #
    #   Vector2d(0, 10).fit_either(constraint) # => Vector2d(0,5)
    #
    # The zero vector has no direction, and is returned unchanged.
    #
    #   Vector2d(0, 0).fit_either(Vector2d(5, 5)) # => Vector2d(0,0)
    #
    def fit_either(other)
      return self if zero?

      v = to_vector(other)
      scale = v.to_f_vector / self
      if [scale.x, scale.y].all? { |s| s.positive? && s.finite? }
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
      factors = [scale.x, scale.y].select { |s| s.finite? && !s.zero? }.map(&:abs)
      return self if factors.empty?

      self * factors.min
    end
  end
end
