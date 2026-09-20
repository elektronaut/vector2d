# frozen_string_literal: true

class Vector2d
  module Fitting
    # Scales the vector to fit inside another vector, retaining the
    # aspect ratio.
    #
    #   vector = Vector2d(20, 10)
    #   vector.fit(Vector2d(10, 10)) # => Vector2d(10.0,5.0)
    #   vector.fit(Vector2d(20, 20)) # => Vector2d(20.0,10.0)
    #   vector.fit(Vector2d(40, 40)) # => Vector2d(40.0,20.0)
    #
    # Pass <tt>upscale: false</tt> to scale down only, leaving a vector
    # that already fits unchanged.
    #
    #   vector.fit(Vector2d(40, 40), upscale: false) # => Vector2d(20,10)
    #   vector.fit(Vector2d(10, 10), upscale: false) # => Vector2d(10.0,5.0)
    #
    # The constraint applies to the magnitude of each coordinate, and
    # the vector keeps its direction.
    #
    #   Vector2d(-20, 10).fit(Vector2d(5, 5)) # => Vector2d(-5.0,2.5)
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
    def fit(other, upscale: true)
      scale_by(fit_factors(coerce_vector(other)).min, upscale: upscale)
    end

    # Scales the vector to cover another vector, retaining the aspect
    # ratio. Where #fit scales until the vector is contained by the
    # constraint, #cover scales until it contains the constraint.
    #
    #   constraint = Vector2d(5, 5)
    #   Vector2d(20, 10).cover(constraint) # => Vector2d(10.0,5.0)
    #   Vector2d(10, 20).cover(constraint) # => Vector2d(5.0,10.0)
    #
    # Pass <tt>upscale: false</tt> to scale down only, leaving a vector
    # that already covers the constraint unchanged.
    #
    #   Vector2d(20, 10).cover(Vector2d(40, 40), upscale: false)
    #   # => Vector2d(20,10)
    #
    # As in #fit, coordinates are constrained by magnitude and the
    # vector keeps its direction.
    #
    #   Vector2d(-20, 10).cover(constraint) # => Vector2d(-10.0,5.0)
    #
    # Note: Either axis will be disregarded if zero or nil, as in #fit.
    # This is a feature, not a bug.
    #
    #   Vector2d(0, 10).cover(constraint) # => Vector2d(0.0,5.0)
    #   Vector2d(20, 10).cover(Vector2d(0, 0)) # => Vector2d(20,10)
    #
    # The zero vector has no direction, and is returned unchanged.
    #
    #   Vector2d(0, 0).cover(Vector2d(5, 5)) # => Vector2d(0,0)
    #
    def cover(other, upscale: true)
      scale_by(fit_factors(coerce_vector(other)).max, upscale: upscale)
    end
    alias fit_either cover

    # @deprecated Use <tt>other.fit(self, upscale: false)</tt> instead.
    #
    # Scales down the given vector unless it fits inside.
    #
    #   vector = Vector2d(20, 20)
    #   vector.contain(Vector2d(10, 10)) # => Vector2d(10,10)
    #   vector.contain(Vector2d(40, 20)) # => Vector2d(20.0,10.0)
    #   vector.contain(Vector2d(20, 40)) # => Vector2d(10.0,20.0)
    #
    # Coordinates are compared by magnitude, so negative vectors are
    # scaled the same way and keep their direction.
    #
    #   vector.contain(Vector2d(-40, 20)) # => Vector2d(-20.0,10.0)
    #
    # An axis that is zero is unconstrained, as in #fit, so the zero
    # vector contains anything.
    #
    #   Vector2d(0, 0).contain(Vector2d(40, 20)) # => Vector2d(40,20)
    #
    def contain(other)
      warn_deprecated("Vector2d#contain is deprecated. " \
                      "Use `other.fit(self, upscale: false)` instead.")
      coerce_vector(other).fit(self, upscale: false)
    end

    # @deprecated Use #fit instead.
    def constrain_both(other)
      warn_deprecated("Vector2d#constrain_both is deprecated. Use #fit instead.")
      fit(other)
    end

    # @deprecated Use #cover instead.
    def constrain_one(other)
      warn_deprecated("Vector2d#constrain_one is deprecated. Use #cover instead.")
      cover(other)
    end

    protected

    # Magnitudes of the scale factor for each axis, disregarding axes
    # that don't constrain the vector.
    def fit_factors(other)
      scale = other.to_f_vector / self
      scale.to_a.select { |s| s.finite? && !s.zero? }.map(&:abs)
    end

    # Scales the vector by the given factor. An unconstrained vector,
    # which has no factor, is returned unchanged, as is one that would
    # grow when +upscale+ is false.
    def scale_by(factor, upscale:)
      return self if factor.nil? || (!upscale && factor >= 1)

      self * factor
    end

    private

    # Warns that a method is deprecated. Silent unless deprecation
    # warnings are enabled, either with <tt>Warning[:deprecated] = true</tt>
    # or by running Ruby with <tt>-w</tt>.
    def warn_deprecated(message)
      warn(message, uplevel: 2, category: :deprecated)
    end
  end
end
