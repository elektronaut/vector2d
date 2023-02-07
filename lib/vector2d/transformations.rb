# frozen_string_literal: true

class Vector2d
  module Transformations
    include Contracts

    # Rounds vector to up nearest integer.
    #
    #   Vector2d(2.4, 3.6).ceil # => Vector2d(3,4)
    #
    Contract None => Vector2d
    def ceil
      self.class.new(x.ceil, y.ceil)
    end

    # Rounds vector to up nearest integer.
    #
    #   Vector2d(2.4, 3.6).floor # => Vector2d(2,3)
    #
    Contract None => Vector2d
    def floor
      self.class.new(x.floor, y.floor)
    end

    # Normalizes the vector.
    #
    #   vector = Vector2d(2, 3)
    #   vector.normalize        # => Vector2d(0.5547.., 0.8320..)
    #   vector.normalize.length # => 1.0
    #
    Contract None => Vector2d
    def normalize
      resize(1.0)
    end

    # Returns a perpendicular vector.
    #
    #   Vector2d(2, 3).perpendicular # => Vector2d(-3,2)
    #
    Contract None => Vector2d
    def perpendicular
      Vector2d.new(-y, x)
    end

    # Changes magnitude of vector.
    #
    #   Vector2d(2, 3).resize(1.0) # => Vector2d(0.5547.., 0.8320..)
    #
    Contract Num => Vector2d
    def resize(new_length)
      self * (new_length / length)
    end

    # Reverses the vector.
    #
    #   Vector2d(2, 3).reverse # => Vector2d(-2,-3)
    #
    Contract None => Vector2d
    def reverse
      self.class.new(-x, -y)
    end

    # Rotates the vector
    #
    #   Vector2d(1, 0).rotate(Math:PI/2) => Vector2d(1,0)
    #
    Contract Num => Vector2d
    def rotate(angle)
      Vector2d.new(
        (x * Math.cos(angle)) - (y * Math.sin(angle)),
        (x * Math.sin(angle)) + (y * Math.cos(angle))
      )
    end

    # Rounds vector to nearest integer.
    #
    #   Vector2d(2.4, 3.6).round # => Vector2d(2,4)
    #   Vector2d(2.4444, 3.666).round(2) # => Vector2d(2.44, 3.67)
    #
    Contract Or[None, Num] => Vector2d
    def round(digits = 0)
      self.class.new(x.round(digits), y.round(digits))
    end

    # Truncates to max length if vector is longer than max.
    #
    #   vector = Vector2d(2.0, 3.0)
    #   vector.truncate(5.0) # => Vector2d(2.0, 3.0)
    #   vector.truncate(1.0) # => Vector2d(0.5547.., 0.8320..)
    #
    Contract Num => Vector2d
    def truncate(max)
      resize([max, length].min)
    end
  end
end
