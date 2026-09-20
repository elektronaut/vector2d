# frozen_string_literal: true

class Vector2d
  # The angle API. Radians are the native unit: every angle is measured
  # counterclockwise from the positive x axis, and every method takes
  # and returns radians unless its name says degrees.
  #
  # The degree methods are conversions layered on top, not a second
  # angle API. Two general converters, .radians and .degrees, do the
  # arithmetic once. Three degree variants build on them, each one the
  # radian method with the angle converted: .from_degrees is
  # .from_angle, #angle_in_degrees is #angle, and #rotate_degrees is
  # #rotate. The rest of the angle API stays radians only. Convert at
  # the call site for those.
  #
  #   Vector2d(2, 3).rotate_around(Vector2d(1, 1), Vector2d.radians(90))
  #   # => Vector2d(-1.0,2.0)
  #
  #   Vector2d.degrees(Vector2d(2, 3).angle_to(Vector2d(4, 5)))
  #   # => -4.9697..
  #
  # Porting note: pygame's rotate() and Unity's Vector2.Angle are in
  # degrees, so those angles need .radians on the way in. Godot and
  # Rust's glam are radians like this library, and their angles carry
  # over unconverted.
  module Angles
    module ClassMethods
      # Calculates the signed angle in radians from the first vector to
      # the second, in the range -PI..PI. The angle is positive when the
      # second vector is counterclockwise from the first, and reversing
      # the arguments flips its sign.
      #
      #   v1 = Vector2d(2, 3)
      #   v2 = Vector2d(4, 5)
      #   Vector2d.angle_to(v1, v2) # => -0.0867..
      #   Vector2d.angle_to(v2, v1) # => 0.0867..
      #
      # Only the directions matter, not the magnitudes. The zero vector
      # has no direction, and the angle to or from it is zero.
      #
      #   Vector2d.angle_to(v1, Vector2d(0, 0)) # => 0.0
      #
      def angle_to(vector1, vector2)
        Math.atan2(cross_product(vector1, vector2),
                   dot_product(vector1, vector2))
      end

      # Calculates the unsigned angle between two vectors in radians, in
      # the range 0..PI. This is the magnitude of .angle_to, so the
      # order of the arguments does not matter.
      #
      #   v1 = Vector2d(2, 3)
      #   v2 = Vector2d(4, 5)
      #   Vector2d.angle_between(v1, v2) # => 0.0867..
      #   Vector2d.angle_between(v2, v1) # => 0.0867..
      #
      # Only the directions matter, not the magnitudes. The zero vector
      # has no direction, and the angle between it and anything is zero.
      #
      #   Vector2d.angle_between(v1, Vector2d(0, 0)) # => 0.0
      #
      def angle_between(vector1, vector2)
        angle_to(vector1, vector2).abs
      end

      # Converts an angle from degrees to radians, the unit the rest of
      # the library speaks. The result is always a float.
      #
      #   Vector2d.radians(0)   # => 0.0
      #   Vector2d.radians(90)  # => 1.5707..
      #   Vector2d.radians(180) # => 3.1415..
      #
      # .degrees converts back.
      #
      #   Vector2d.degrees(Vector2d.radians(90)) # => 90.0
      #
      # Raises ArgumentError unless the angle is a real number.
      # Complex numbers are not angles, and are rejected.
      #
      #   Vector2d.radians(Complex(1, 2)) # => ArgumentError
      #
      def radians(degrees)
        coordinate(degrees).to_f * Math::PI / 180
      end

      # Converts an angle from radians to degrees, the inverse of
      # .radians. The result is always a float.
      #
      #   Vector2d.degrees(0)            # => 0.0
      #   Vector2d.degrees(Math::PI / 2) # => 90.0
      #   Vector2d.degrees(Math::PI)     # => 180.0
      #
      # This is the conversion #angle_in_degrees applies to #angle, and
      # the one to reach for with the angle methods that have no degree
      # variant.
      #
      #   Vector2d.degrees(Vector2d(0, 1).angle) # => 90.0
      #
      # Raises ArgumentError unless the angle is a real number.
      # Complex numbers are not angles, and are rejected.
      #
      #   Vector2d.degrees(Complex(1, 2)) # => ArgumentError
      #
      def degrees(radians)
        coordinate(radians).to_f * 180 / Math::PI
      end

      # Creates a vector from an angle in degrees, with an optional
      # length. This is .from_angle with the angle put through
      # .radians, and is the same in every other respect: angles are
      # measured counterclockwise from the positive x axis, and
      # coordinates are always floats.
      #
      #   Vector2d.from_degrees(0)       # => Vector2d(1.0,0.0)
      #   Vector2d.from_degrees(45)      # => Vector2d(0.7071..,0.7071..)
      #   Vector2d.from_degrees(45, 2.0) # => Vector2d(1.4142..,1.4142..)
      #
      # #angle_in_degrees takes the angle back.
      #
      #   Vector2d.from_degrees(90).angle_in_degrees # => 90.0
      #
      # Raises ArgumentError unless both arguments are real numbers.
      #
      #   Vector2d.from_degrees(Complex(1, 2)) # => ArgumentError
      #
      def from_degrees(angle, length = 1.0)
        from_angle(radians(angle), length)
      end
    end

    # Angle of vector.
    #
    #   Vector2d(2, 3).angle # => 0.9827..
    #
    def angle
      Math.atan2(y, x)
    end

    # Signed angle in radians from this vector to another vector, in the
    # range -PI..PI. The angle is positive when the other vector is
    # counterclockwise from this one.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(4, 5)
    #   v1.angle_to(v2) # => -0.0867..
    #   v2.angle_to(v1) # => 0.0867..
    #
    # Only the directions matter, not the magnitudes. The zero vector
    # has no direction, and the angle to or from it is zero.
    #
    #   v1.angle_to(Vector2d(0, 0)) # => 0.0
    #
    def angle_to(other)
      v = coerce_vector(other)
      self.class.angle_to(self, v)
    end

    # Unsigned angle in radians between this vector and another vector,
    # in the range 0..PI. This is the magnitude of #angle_to, so it is
    # the same in either direction.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(4, 5)
    #   v1.angle_between(v2) # => 0.0867..
    #   v2.angle_between(v1) # => 0.0867..
    #
    # Only the directions matter, not the magnitudes. The zero vector
    # has no direction, and the angle between it and anything is zero.
    #
    #   v1.angle_between(Vector2d(0, 0)) # => 0.0
    #
    def angle_between(other)
      angle_to(other).abs
    end
    alias angle_with angle_between

    # Polar coordinates of vector, as a [length, angle] array.
    #
    #   Vector2d(2, 3).to_polar # => [3.6055.., 0.9827..]
    #
    # Vector2d.from_angle takes the same pair back.
    #
    #   length, angle = Vector2d(2, 3).to_polar
    #   Vector2d.from_angle(angle, length) # => Vector2d(2.0,3.0)
    #
    def to_polar
      [length, angle]
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

    # Returns the vector rotated a quarter turn clockwise.
    #
    #   Vector2d(2, 3).perpendicular_cw # => Vector2d(3,-2)
    #
    def perpendicular_cw
      build(y, -x)
    end

    # Angle of the vector in degrees. This is #angle put through
    # .degrees, and follows the same convention: angles are measured
    # counterclockwise from the positive x axis, in the range
    # -180..180.
    #
    #   Vector2d(1, 0).angle_in_degrees  # => 0.0
    #   Vector2d(0, 1).angle_in_degrees  # => 90.0
    #   Vector2d(2, 3).angle_in_degrees  # => 56.3099..
    #   Vector2d(0, -1).angle_in_degrees # => -90.0
    #
    # Vector2d.from_degrees takes the angle back.
    #
    #   Vector2d.from_degrees(Vector2d(2, 3).angle_in_degrees, 5.0)
    #   # => Vector2d(2.7735..,4.1602..)
    #
    def angle_in_degrees
      self.class.degrees(angle)
    end

    # Rotates the vector around the origin by an angle in degrees. This
    # is #rotate with the angle put through .radians, and turns the
    # same way: a positive angle turns counterclockwise.
    #
    #   Vector2d(2, 3).rotate_degrees(90) # => Vector2d(-3.0,2.0)
    #
    # The two agree exactly wherever .radians lands on the angle
    # #rotate would have been given.
    #
    #   Vector2d(2, 3).rotate_degrees(90) == Vector2d(2, 3).rotate(Math::PI / 2)
    #   # => true
    #
    # Raises ArgumentError unless the angle is a real number.
    #
    #   Vector2d(2, 3).rotate_degrees(Complex(1, 2)) # => ArgumentError
    #
    def rotate_degrees(angle)
      rotate(self.class.radians(angle))
    end
  end
end
