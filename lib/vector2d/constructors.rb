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
    #
    # @param angle [Integer, Float, Rational, BigDecimal] the angle in radians
    # @param length [Integer, Float, Rational, BigDecimal]
    #   the length of the vector
    # @return [Vector2d] a vector of the receiver's class
    def from_angle(angle, length = 1.0)
      angle = coordinate(angle).to_f
      length = coordinate(length).to_f
      build(Math.cos(angle) * length, Math.sin(angle) * length)
    end

    # Creates a random vector, uniformly distributed by angle, with an
    # optional length. Coordinates are always floats, as with
    # .from_angle.
    #
    #   Vector2d.random.length.round(6)      # => 1.0
    #   Vector2d.random(2.0).length.round(6) # => 2.0
    #
    # Pass a Random to draw from a seeded sequence.
    #
    #   a = Vector2d.random(random: Random.new(42))
    #   b = Vector2d.random(random: Random.new(42))
    #   a == b # => true
    #
    # Raises ArgumentError unless the length is a real number.
    #
    #   Vector2d.random(Complex(1, 2)) # => ArgumentError
    #
    # @param length [Integer, Float, Rational, BigDecimal]
    #   the length of the vector
    # @param random [#rand] the source of randomness
    # @return [Vector2d] a vector of the receiver's class
    def random(length = 1.0, random: Random)
      from_angle(random.rand * 2 * Math::PI, length)
    end

    # The zero vector.
    #
    #   Vector2d.zero # => Vector2d(0,0)
    #
    # This and the five constants below have integer coordinates. They
    # are exact, and integers keep them exact through arithmetic with
    # integer vectors, widening to floats only when a float is
    # involved. .from_angle returns floats instead, because a general
    # angle has no exact coordinates.
    #
    #   Vector2d.zero.x       # => 0
    #   (Vector2d.up * 2).y   # => 2
    #   (Vector2d.up * 0.5).y # => 0.5
    #
    # @return [Vector2d] a vector of the receiver's class
    def zero
      build(0, 0)
    end

    # The vector with both coordinates set to one.
    #
    #   Vector2d.one # => Vector2d(1,1)
    #
    # @return [Vector2d] a vector of the receiver's class
    def one
      build(1, 1)
    end

    # The unit vector pointing up.
    #
    #   Vector2d.up       # => Vector2d(0,1)
    #   Vector2d.up.angle # => 1.5707..
    #
    # The y axis grows upwards here, and angles turn counterclockwise
    # from the positive x axis. That is the convention .from_angle,
    # #angle, #rotate and #perpendicular all follow. Libraries drawing
    # in screen coordinates grow the y axis downwards and call (0, -1)
    # up, so flip the y axis at that boundary.
    #
    # @return [Vector2d] a vector of the receiver's class
    def up
      build(0, 1)
    end

    # The unit vector pointing down. See .up for the direction the y
    # axis grows in.
    #
    #   Vector2d.down       # => Vector2d(0,-1)
    #   Vector2d.down.angle # => -1.5707..
    #
    # @return [Vector2d] a vector of the receiver's class
    def down
      build(0, -1)
    end

    # The unit vector pointing left.
    #
    #   Vector2d.left       # => Vector2d(-1,0)
    #   Vector2d.left.angle # => 3.1415..
    #
    # @return [Vector2d] a vector of the receiver's class
    def left
      build(-1, 0)
    end

    # The unit vector pointing right, along the positive x axis. This
    # is the direction angles are measured from.
    #
    #   Vector2d.right       # => Vector2d(1,0)
    #   Vector2d.right.angle # => 0.0
    #
    # @return [Vector2d] a vector of the receiver's class
    def right
      build(1, 0)
    end
  end
end
