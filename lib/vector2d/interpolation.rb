# frozen_string_literal: true

class Vector2d
  # Interpolation between two vectors, and stepping from one toward
  # another.
  module Interpolation
    # Linearly interpolates between this vector and another vector.
    #
    #   v1 = Vector2d(0, 0)
    #   v2 = Vector2d(10, 20)
    #   v1.lerp(v2, 0.0)  # => Vector2d(0.0,0.0)
    #   v1.lerp(v2, 0.25) # => Vector2d(2.5,5.0)
    #   v1.lerp(v2, 1.0)  # => Vector2d(10.0,20.0)
    #
    # The amount is not clamped to 0..1. Values outside that range
    # extrapolate past the end points.
    #
    #   v1.lerp(v2, 2.0)  # => Vector2d(20.0,40.0)
    #   v1.lerp(v2, -0.5) # => Vector2d(-5.0,-10.0)
    #
    # Raises ArgumentError unless the amount is a real number. One
    # amount applies to both axes.
    #
    #   v1.lerp(v2, Vector2d(0.25, 0.5)) # => ArgumentError
    #
    # @!macro coercible
    # @param amount [Integer, Float, Rational, BigDecimal]
    #   the position along the segment
    # @return [self]
    def lerp(other, amount)
      v = coerce_vector(other)
      amount = coordinate(amount)
      build(interpolate(x, v.x, amount), interpolate(y, v.y, amount))
    end

    # Returns the amount #lerp would need to land on a value, the
    # position of that value along the segment from this vector to
    # another one. This is the inverse of #lerp.
    #
    #   v1 = Vector2d(0, 0)
    #   v2 = Vector2d(10, 20)
    #   v1.inverse_lerp(v2, Vector2d(2.5, 5.0)) # => 0.25
    #   v1.inverse_lerp(v2, v1)                 # => 0.0
    #   v1.inverse_lerp(v2, v2)                 # => 1.0
    #
    # The result is a scalar, one amount for both axes, matching the
    # single amount #lerp takes.
    #
    #   v1.lerp(v2, v1.inverse_lerp(v2, Vector2d(2.5, 5.0))) # => Vector2d(2.5,5.0)
    #
    # The value does not have to lie on the segment. Anything off it is
    # projected onto the line through the end points first, so the
    # result is the position of the nearest point on that line.
    #
    #   v1.inverse_lerp(v2, Vector2d(5, 0)) # => 0.1
    #
    # The result is not clamped to 0..1, the same way the amount #lerp
    # takes is not. Values beyond the end points fall outside it.
    #
    #   v1.inverse_lerp(v2, Vector2d(20, 40))  # => 2.0
    #   v1.inverse_lerp(v2, Vector2d(-5, -10)) # => -0.5
    #
    # A segment between two identical vectors has no length to measure
    # along, and no amount reaches anything but its own end point. Zero
    # is returned.
    #
    #   v1.inverse_lerp(v1, Vector2d(2.5, 5.0)) # => 0.0
    #
    # @!macro coercible
    # @param value [Vector2d, Array, String, Hash, Integer, Float, Rational,
    #   BigDecimal, ::Vector, ::Matrix] the value to locate, anything
    #   Vector2d.parse accepts
    # @return [Float] the amount #lerp would take to reach the value
    def inverse_lerp(other, value)
      segment = coerce_vector(other) - self
      return 0.0 if segment.zero?

      (coerce_vector(value) - self).dot_product(segment).to_f / segment.length_squared
    end

    # Spherically interpolates between this vector and another vector.
    # The vector turns through the angle between the two, while the
    # length is interpolated linearly. The other vector is coerced, so
    # scalars work too.
    #
    #   v1 = Vector2d(2, 0)
    #   v2 = Vector2d(0, 4)
    #   v1.slerp(v2, 0.5) # => Vector2d(2.1213..,2.1213..)
    #
    # Where #lerp moves along the straight line between the two
    # vectors, #slerp moves along the arc between them, so the length
    # follows the end points instead of cutting the corner.
    #
    #   v1.lerp(v2, 0.5).length  # => 2.2360..
    #   v1.slerp(v2, 0.5).length # => 3.0
    #
    # Vectors pointing in opposite directions are half a turn apart
    # either way around. The turn is counterclockwise, the direction
    # #rotate takes a positive angle in.
    #
    #   half = Vector2d(2, 0).slerp(Vector2d(-2, 0), 0.5)
    #   half.angle  # => 1.5707..
    #   half.length # => 2.0
    #
    # The zero vector has no direction to turn from or to, and there is
    # no arc to follow. #lerp is used instead.
    #
    #   Vector2d(0, 0).slerp(v2, 0.5) # => Vector2d(0.0,2.0)
    #
    # The amount is not clamped to 0..1, and behaves as it does in
    # #lerp. Values outside that range keep turning past the end
    # points.
    #
    #   v1.slerp(v2, 2.0).angle # => 3.1415..
    #
    # @!macro coercible
    # @param amount [Integer, Float, Rational, BigDecimal]
    #   the position along the segment
    # @return [self]
    def slerp(other, amount)
      v = coerce_vector(other)
      amount = coordinate(amount)
      return lerp(v, amount) if zero? || v.zero?

      rotate(slerp_angle(v) * amount) *
        (interpolate(length, v.length, amount) / length)
    end

    # Returns the point halfway between this vector and another vector.
    #
    #   v1 = Vector2d(0, 0)
    #   v2 = Vector2d(10, 20)
    #   v1.midpoint(v2) # => Vector2d(5.0,10.0)
    #
    # @!macro coercible
    # @return [self]
    def midpoint(other)
      lerp(other, 0.5)
    end

    # Moves this vector toward another vector by a fixed distance,
    # stopping at the target instead of overshooting it. The target is
    # coerced, so scalars work too.
    #
    #   v1 = Vector2d(0, 0)
    #   v2 = Vector2d(10, 0)
    #   v1.move_toward(v2, 2)  # => Vector2d(2.0,0.0)
    #   v1.move_toward(v2, 20) # => Vector2d(10,0)
    #
    # Where #lerp takes a fraction of the way there, this takes a
    # distance, so the step is the same size however far off the target
    # is.
    #
    # A negative distance moves away from the target, and has nothing
    # to overshoot.
    #
    #   v1.move_toward(v2, -2) # => Vector2d(-2.0,0.0)
    #
    # There is nowhere to move when the vector is already at the
    # target, whatever the distance. The target is returned.
    #
    #   v2.move_toward(v2, 2) # => Vector2d(10,0)
    #
    # @!macro coercible
    # @param distance [Integer, Float, Rational, BigDecimal] how far to move
    # @return [self]
    def move_toward(target, distance)
      v = coerce_vector(target)
      distance = coordinate(distance)
      delta = build(v.x - x, v.y - y)
      return build(v.x, v.y) if delta.zero? || distance >= delta.length

      self + delta.resize(distance)
    end

    private

    # The angle #slerp turns through. Vectors pointing in opposite
    # directions are half a turn apart either way around, and the
    # counterclockwise one is taken.
    def slerp_angle(other)
      return Math::PI if parallel?(other) && dot_product(other).negative?

      angle_to(other)
    end

    def interpolate(start, finish, amount)
      start + ((finish - start) * amount)
    end
  end
end
