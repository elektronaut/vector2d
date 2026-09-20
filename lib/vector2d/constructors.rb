# frozen_string_literal: true

class Vector2d
  # The constructors that build a vector from something other than
  # coordinates: an angle, a random draw, or a direction. They are
  # class methods rather than constants, so a subclass gets its own.
  module Constructors
    # Creates a vector from an angle in radians, with an optional
    # length. Angles are measured counterclockwise from the positive x
    # axis, the same convention #angle follows.
    #
    #   Vector2d.from_angle(0)                 # => Vector2d(1.0,0.0)
    #   Vector2d.from_angle(Math::PI / 4)      # => Vector2d(0.7071..,0.7071..)
    #   Vector2d.from_angle(Math::PI / 4, 2.0) # => Vector2d(1.4142..,1.4142..)
    #
    # Coordinates are always floats. This is the inverse of #to_polar.
    #
    #   length, angle = Vector2d(2, 3).to_polar
    #   Vector2d.from_angle(angle, length) # => Vector2d(2.0,3.0)
    #
    # Raises ArgumentError unless both arguments are real numbers.
    # Complex numbers are not coordinates, and are rejected.
    #
    #   Vector2d.from_angle(Complex(1, 2)) # => ArgumentError
    def from_angle(angle, length = 1.0)
      angle = coordinate(angle)
      length = coordinate(length)
      build(Math.cos(angle) * length, Math.sin(angle) * length)
    end
  end
end
