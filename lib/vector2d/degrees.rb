# frozen_string_literal: true

class Vector2d
  # Degrees, for code that thinks in them. Radians are the native unit
  # of this library: every other angle method takes and returns them,
  # and none of them change behaviour because this module exists. The
  # methods here are conversions layered on top, not a second angle
  # API.
  #
  # Two general converters, .radians and .degrees, do the arithmetic
  # once. Three degree variants build on them, each one the radian
  # method with the angle converted: .from_degrees is .from_angle,
  # #angle_in_degrees is #angle, and #rotate_degrees is #rotate.
  #
  # The rest of the angle API stays radians only. Convert at the call
  # site for those.
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
  module Degrees
    module ClassMethods
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
        coordinate(degrees) * Math::PI / 180
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
        coordinate(radians) * 180 / Math::PI
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
