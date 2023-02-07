# frozen_string_literal: true

class Vector2d
  module Properties
    include Contracts

    # Angle of vector.
    #
    #   Vector2d(2, 3).angle # => 0.9827..
    #
    Contract None => Num
    def angle
      Math.atan2(y, x)
    end

    # Aspect ratio of vector.
    #
    #   Vector2d(2, 3).aspect_ratio # => 0.6667..
    #
    Contract None => Num
    def aspect_ratio
      (x.to_f / y).abs
    end

    # Length of vector.
    #
    #   Vector2d(2, 3).length # => 3.6055..
    #
    Contract None => Num
    def length
      Math.sqrt(squared_length)
    end

    # Squared length of vector.
    #
    #   Vector2d(2, 3).squared_length # => 13
    #
    Contract None => Num
    def squared_length
      (x * x) + (y * y)
    end

    # Is this a normalized vector?
    #
    #   Vector2d(0, 1).normalized? # => true
    #   Vector2d(2, 3).normalized? # => false
    #
    Contract None => Bool
    def normalized?
      (length.to_f - 1.0).abs < Float::EPSILON
    end
  end
end
