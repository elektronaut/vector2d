# frozen_string_literal: true

class Vector2d
  module Transformations
    # Returns the absolute value of each axis. This is component-wise,
    # not the magnitude of the vector, which is #length.
    #
    #   Vector2d(-2, 3).abs  # => Vector2d(2,3)
    #   Vector2d(-2, -3).abs # => Vector2d(2,3)
    #
    def abs
      build(x.abs, y.abs)
    end

    # Rounds vector up to nearest integer.
    #
    #   Vector2d(2.4, 3.6).ceil        # => Vector2d(3,4)
    #   Vector2d(2.441, 3.666).ceil(2) # => Vector2d(2.45,3.67)
    #
    def ceil(digits = 0)
      build(x.ceil(digits), y.ceil(digits))
    end

    # Clamps the vector between two others, one axis at a time. The
    # bounds are coerced, so scalars work too.
    #
    #   vector = Vector2d(2, 8)
    #   vector.clamp(Vector2d(3, 3), Vector2d(6, 6)) # => Vector2d(3,6)
    #   vector.clamp(3, 6)                           # => Vector2d(3,6)
    #
    # The bounds can also be given as a single range, which may be
    # beginless or endless to clamp only one side.
    #
    #   vector.clamp(3..6) # => Vector2d(3,6)
    #   vector.clamp(..6)  # => Vector2d(2,6)
    #   vector.clamp(3..)  # => Vector2d(3,8)
    #
    # The range must not exclude its end, as with Comparable#clamp.
    #
    #   vector.clamp(3...6) # => ArgumentError
    #
    def clamp(min, max = nil)
      min_v, max_v = clamp_bounds(min, max)
      build(
        x.clamp(Range.new(min_v&.x, max_v&.x)),
        y.clamp(Range.new(min_v&.y, max_v&.y))
      )
    end

    # Clamps the length of the vector, scaling it down if it is longer
    # than max.
    #
    #   vector = Vector2d(2.0, 3.0)
    #   vector.clamp_length(5.0) # => Vector2d(2.0, 3.0)
    #   vector.clamp_length(1.0) # => Vector2d(0.5547.., 0.8320..)
    #
    # The zero vector has no direction, and is returned unchanged.
    #
    #   Vector2d(0, 0).clamp_length(1.0) # => Vector2d(0,0)
    #
    # The max length can't be negative.
    #
    #   Vector2d(2, 3).clamp_length(-1.0) # => ArgumentError
    #
    def clamp_length(max)
      raise ArgumentError, "negative max length: #{max}" if coordinate(max).negative?

      resize([max, length].min)
    end

    # Rounds vector down to nearest integer.
    #
    #   Vector2d(2.4, 3.6).floor        # => Vector2d(2,3)
    #   Vector2d(2.444, 3.669).floor(2) # => Vector2d(2.44,3.66)
    #
    def floor(digits = 0)
      build(x.floor(digits), y.floor(digits))
    end

    # Returns the larger value of each axis. The other vector is
    # coerced, so scalars work too.
    #
    #   vector = Vector2d(2, 8)
    #   vector.max(Vector2d(5, 5)) # => Vector2d(5,8)
    #   vector.max(5)              # => Vector2d(5,8)
    #
    def max(other)
      v = coerce_vector(other)
      build([x, v.x].max, [y, v.y].max)
    end

    # Returns the smaller value of each axis. The other vector is
    # coerced, so scalars work too.
    #
    #   vector = Vector2d(2, 8)
    #   vector.min(Vector2d(5, 5)) # => Vector2d(2,5)
    #   vector.min(5)              # => Vector2d(2,5)
    #
    def min(other)
      v = coerce_vector(other)
      build([x, v.x].min, [y, v.y].min)
    end

    # Normalizes the vector.
    #
    #   vector = Vector2d(2, 3)
    #   vector.normalize        # => Vector2d(0.5547.., 0.8320..)
    #   vector.normalize.length # => 1.0
    #
    # The zero vector has no direction, and is returned unchanged.
    #
    #   Vector2d(0, 0).normalize # => Vector2d(0,0)
    #
    def normalize
      resize(1.0)
    end

    # Returns the vector rotated a quarter turn counterclockwise.
    #
    #   Vector2d(2, 3).perpendicular # => Vector2d(-3,2)
    #
    # Counterclockwise is the same positive direction #rotate turns in.
    # Use #perpendicular_cw for the other one.
    #
    def perpendicular
      build(-y, x)
    end
    alias perpendicular_ccw perpendicular

    # Returns the vector rotated a quarter turn clockwise.
    #
    #   Vector2d(2, 3).perpendicular_cw # => Vector2d(3,-2)
    #
    def perpendicular_cw
      build(y, -x)
    end

    # Changes magnitude of vector.
    #
    #   Vector2d(2, 3).resize(1.0) # => Vector2d(0.5547.., 0.8320..)
    #
    # The zero vector has no direction, and is returned unchanged.
    #
    #   Vector2d(0, 0).resize(1.0) # => Vector2d(0,0)
    #
    # A negative length reverses the vector.
    #
    #   Vector2d(2, 3).resize(-1.0) # => Vector2d(-0.5547..,-0.8320..)
    #
    def resize(new_length)
      new_length = coordinate(new_length)
      return self if zero?

      self * (new_length / length)
    end

    # Reverses the vector.
    #
    #   Vector2d(2, 3).reverse # => Vector2d(-2,-3)
    #
    def reverse
      build(-x, -y)
    end

    # Rotates the vector around the origin. The angle is in radians, and
    # a positive angle turns counterclockwise.
    #
    #   Vector2d(2, 3).rotate(Math::PI / 2) # => Vector2d(-3.0,2.0)
    #
    # Raises ArgumentError unless the angle is a real number.
    #
    #   Vector2d(2, 3).rotate(Complex(1, 2)) # => ArgumentError
    #
    def rotate(angle)
      angle = coordinate(angle)
      cos = Math.cos(angle)
      sin = Math.sin(angle)
      build((x * cos) - (y * sin), (x * sin) + (y * cos))
    end

    # Rotates the vector around another point. The center is coerced, so
    # scalars work too. The angle is in radians, and a positive angle
    # turns counterclockwise.
    #
    #   Vector2d(2, 1).rotate_around(Vector2d(1, 1), Math::PI / 2)
    #   # => Vector2d(1.0,2.0)
    #
    def rotate_around(center, angle)
      center_v = coerce_vector(center)
      (self - center_v).rotate(angle) + center_v
    end

    # Rounds vector to nearest integer.
    #
    #   Vector2d(2.4, 3.6).round         # => Vector2d(2,4)
    #   Vector2d(2.4444, 3.666).round(2) # => Vector2d(2.44,3.67)
    #
    def round(digits = 0)
      build(x.round(digits), y.round(digits))
    end

    # @deprecated Use #clamp_length instead. The name belongs to the
    # #ceil/#floor/#round family, which maps Numeric over both
    # coordinates.
    def truncate(max)
      warn_deprecated("Vector2d#truncate is deprecated. Use #clamp_length instead.")
      clamp_length(max)
    end

    # Snaps each axis to the nearest multiple of a step. The step is
    # coerced, so scalars work too, and a vector gives each axis its
    # own step.
    #
    #   vector = Vector2d(23, 47)
    #   vector.snap(10)              # => Vector2d(20,50)
    #   vector.snap(Vector2d(10, 5)) # => Vector2d(20,45)
    #
    # Coordinates take the type of the step, so an integer step snaps
    # to integers.
    #
    #   Vector2d(2.3, 3.7).snap(1)   # => Vector2d(2,4)
    #   Vector2d(2.3, 3.7).snap(0.5) # => Vector2d(2.5,3.5)
    #
    # A step of zero has no multiples to snap to, and leaves the axis
    # unchanged.
    #
    #   vector.snap(0)               # => Vector2d(23,47)
    #   vector.snap(Vector2d(10, 0)) # => Vector2d(20,47)
    #
    def snap(step)
      v = coerce_vector(step)
      build(snap_coordinate(x, v.x), snap_coordinate(y, v.y))
    end

    # Truncates each axis toward zero, the component-wise companion to
    # #ceil and #floor.
    #
    #   Vector2d(2.7, -2.7).trunc # => Vector2d(2,-2)
    #   Vector2d(2.7, -2.7).floor # => Vector2d(2,-3)
    #
    # An optional number of digits keeps that many decimals, as in
    # #ceil, #floor and #round.
    #
    #   Vector2d(2.77, -2.77).trunc(1) # => Vector2d(2.7,-2.7)
    #
    # The shorter name leaves #truncate to its deprecated meaning of
    # #clamp_length, which scales the whole vector.
    #
    def trunc(digits = 0)
      build(x.truncate(digits), y.truncate(digits))
    end

    private

    # Rounds a coordinate to the nearest multiple of a step. A step of
    # zero has no multiples, and the coordinate is left alone.
    def snap_coordinate(value, step)
      return value if step.zero?

      (value / step.to_f).round * step
    end

    def clamp_bounds(min, max)
      if min.is_a?(Range)
        raise ArgumentError, "wrong number of arguments (given 2, expected 1)" unless max.nil?

        return range_bounds(min)
      end

      raise ArgumentError, "wrong number of arguments (given 1, expected 2)" if max.nil?

      [coerce_vector(min), coerce_vector(max)]
    end

    def range_bounds(range)
      raise ArgumentError, "cannot clamp with an exclusive range" if range.exclude_end?

      [range.begin && coerce_vector(range.begin), range.end && coerce_vector(range.end)]
    end
  end
end
