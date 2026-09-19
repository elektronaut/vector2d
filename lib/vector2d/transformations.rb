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
    #   Vector2d(2.4, 3.6).ceil # => Vector2d(3,4)
    #
    def ceil
      build(x.ceil, y.ceil)
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
    def clamp_length(max)
      resize([max, length].min)
    end
    alias truncate clamp_length

    # Rounds vector down to nearest integer.
    #
    #   Vector2d(2.4, 3.6).floor # => Vector2d(2,3)
    #
    def floor
      build(x.floor, y.floor)
    end

    # Returns the larger value of each axis. The other vector is
    # coerced, so scalars work too.
    #
    #   vector = Vector2d(2, 8)
    #   vector.max(Vector2d(5, 5)) # => Vector2d(5,8)
    #   vector.max(5)              # => Vector2d(5,8)
    #
    def max(other)
      v = to_vector(other)
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
      v = to_vector(other)
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
    def resize(new_length)
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
    def rotate(angle)
      build(
        (x * Math.cos(angle)) - (y * Math.sin(angle)),
        (x * Math.sin(angle)) + (y * Math.cos(angle))
      )
    end

    # Rotates the vector around another point. The center is coerced, so
    # scalars work too. The angle is in radians, and a positive angle
    # turns counterclockwise.
    #
    #   Vector2d(2, 1).rotate_around(Vector2d(1, 1), Math::PI / 2)
    #   # => Vector2d(1.0,2.0)
    #
    def rotate_around(center, angle)
      center_v = to_vector(center)
      (self - center_v).rotate(angle) + center_v
    end

    # Rounds vector to nearest integer.
    #
    #   Vector2d(2.4, 3.6).round # => Vector2d(2,4)
    #   Vector2d(2.4444, 3.666).round(2) # => Vector2d(2.44, 3.67)
    #
    def round(digits = 0)
      build(x.round(digits), y.round(digits))
    end

    private

    def clamp_bounds(min, max)
      if min.is_a?(Range)
        raise ArgumentError, "wrong number of arguments (given 2, expected 1)" unless max.nil?

        return range_bounds(min)
      end

      raise ArgumentError, "wrong number of arguments (given 1, expected 2)" if max.nil?

      [to_vector(min), to_vector(max)]
    end

    def range_bounds(range)
      raise ArgumentError, "cannot clamp with an exclusive range" if range.exclude_end?

      [range.begin && to_vector(range.begin), range.end && to_vector(range.end)]
    end
  end
end
