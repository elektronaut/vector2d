# frozen_string_literal: true

class Vector2d
  # The vector as a rectangle. Vector2d grew out of handling image
  # dimensions, and these methods describe a size and fit one inside
  # another. All of them compare coordinates by magnitude, so a
  # negative vector describes the same rectangle as its positive twin.
  module Dimensions
    # Area covered by the vector, the product of its coordinates.
    # Coordinates are taken by magnitude, as in #aspect_ratio, so the
    # area is never negative.
    #
    #   Vector2d(2, 3).area  # => 6
    #   Vector2d(-2, 3).area # => 6
    #
    # A vector without width or height covers nothing.
    #
    #   Vector2d(2, 0).area # => 0
    #
    def area
      (x * y).abs
    end

    # Aspect ratio of vector.
    #
    #   Vector2d(2, 3).aspect_ratio # => 0.6666..
    #
    # A vector without height has no aspect ratio, so ArgumentError is
    # raised.
    #
    #   Vector2d(2, 0).aspect_ratio # => ArgumentError
    #   Vector2d(0, 0).aspect_ratio # => ArgumentError
    #
    def aspect_ratio
      raise ArgumentError, "the zero vector has no aspect ratio" if zero?
      raise ArgumentError, "#{inspect} has no aspect ratio, y is zero" if y.zero?

      (x.to_f / y).abs
    end

    # Is the vector wider than it is tall?
    #
    #   Vector2d(3, 2).landscape? # => true
    #   Vector2d(2, 3).landscape? # => false
    #   Vector2d(2, 2).landscape? # => false
    #
    # Coordinates are compared by magnitude, as in #aspect_ratio.
    #
    #   Vector2d(-3, 2).landscape? # => true
    #
    def landscape?
      x.abs > y.abs
    end

    # Is the vector taller than it is wide?
    #
    #   Vector2d(2, 3).portrait? # => true
    #   Vector2d(3, 2).portrait? # => false
    #   Vector2d(2, 2).portrait? # => false
    #
    # Coordinates are compared by magnitude, as in #aspect_ratio.
    #
    #   Vector2d(2, -3).portrait? # => true
    #
    def portrait?
      x.abs < y.abs
    end

    # Is the vector as wide as it is tall?
    #
    #   Vector2d(2, 2).square? # => true
    #   Vector2d(2, 3).square? # => false
    #
    # Coordinates are compared by magnitude, as in #aspect_ratio.
    # Exactly one of #square?, #landscape? and #portrait? holds for any
    # vector.
    #
    #   Vector2d(-2, 2).square? # => true
    #
    # Unlike #aspect_ratio, these three don't single out the zero
    # vector. It is square.
    #
    #   Vector2d(0, 0).square? # => true
    #
    def square?
      x.abs == y.abs
    end

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

    # Does the vector already fit inside another vector? True whenever
    # <tt>fit(other, upscale: false)</tt> would leave it unchanged.
    #
    #   constraint = Vector2d(20, 20)
    #   Vector2d(20, 10).fits?(constraint) # => true
    #   Vector2d(40, 10).fits?(constraint) # => false
    #
    # A vector that exactly matches the constraint fits.
    #
    #   Vector2d(20, 20).fits?(constraint) # => true
    #
    # Coordinates are compared by magnitude, as in #fit.
    #
    #   Vector2d(-20, 10).fits?(constraint) # => true
    #
    # Note: Either axis will be disregarded if zero or nil, as in #fit.
    # An axis that doesn't constrain can't be overflowed either.
    #
    #   Vector2d(40, 10).fits?(Vector2d(0, 20)) # => true
    #
    # The zero vector has no size, and fits inside anything.
    #
    #   Vector2d(0, 0).fits?(constraint) # => true
    #
    def fits?(other)
      factor = fit_factors(coerce_vector(other)).min
      factor.nil? || factor >= 1
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

    # Does the vector already cover another vector? True whenever
    # #cover would shrink the vector or leave it alone, rather than
    # scaling it up. This is the predicate to #cover that #fits? is to
    # #fit.
    #
    #   constraint = Vector2d(5, 5)
    #   Vector2d(20, 10).covers?(constraint) # => true
    #   Vector2d(20, 1).covers?(constraint)  # => false
    #
    # Coordinates are compared by magnitude, as in #cover.
    #
    #   Vector2d(-20, 10).covers?(constraint) # => true
    #
    # Note: Either axis will be disregarded if zero or nil, as in
    # #cover, so a vector flat on one axis still counts as covering.
    #
    #   Vector2d(0, 10).covers?(constraint)  # => true
    #   Vector2d(0, 0).covers?(constraint)   # => true
    #
    def covers?(other)
      factor = fit_factors(coerce_vector(other)).max
      factor.nil? || factor <= 1
    end

    # @deprecated Use #cover instead.
    def fit_either(other)
      warn_deprecated("Vector2d#fit_either is deprecated. Use #cover instead.")
      cover(other)
    end

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
  end
end
