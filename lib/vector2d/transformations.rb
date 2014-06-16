# encoding: utf-8

class Vector2d
  module Transformations
    # Rounds vector to up nearest integer.
    #
    #   Vector2d(2.4, 3.6).ceil # => Vector2d(3,4)
    #
    def ceil
      self.class.new(x.ceil, y.ceil)
    end

    # Rounds vector to up nearest integer.
    #
    #   Vector2d(2.4, 3.6).floor # => Vector2d(2,3)
    #
    def floor
      self.class.new(x.floor, y.floor)
    end

    # Normalizes the vector.
    #
    #   vector = Vector2d(2, 3)
    #   vector.normalize        # => Vector2d(0.5547.., 0.8320..)
    #   vector.normalize.length # => 1.0
    #
    def normalize
      resize(1.0)
    end

    # Returns a perpendicular vector.
    #
    #   Vector2d(2, 3).perpendicular # => Vector2d(-3,2)
    #
    def perpendicular
      Vector2d.new(-y, x)
    end

    # Changes magnitude of vector.
    #
    #   Vector2d(2, 3).resize(1.0) # => Vector2d(0.5547.., 0.8320..)
    #
    def resize(new_length)
      self * (new_length / self.length)
    end

    # Reverses the vector.
    #
    #   Vector2d(2, 3).reverse # => Vector2d(-2,-3)
    #
    def reverse
      self.class.new(-x, -y)
    end

    # Rounds vector to nearest integer.
    #
    #   Vector2d(2.4, 3.6).round # => Vector2d(2,4)
    #
    def round
      self.class.new(x.round, y.round)
    end

    # Truncates to max length if vector is longer than max.
    #
    #   vector = Vector2d(2.0, 3.0)
    #   vector.truncate(5.0) # => Vector2d(2.0, 3.0)
    #   vector.truncate(1.0) # => Vector2d(0.5547.., 0.8320..)
    #
    def truncate(max)
      resize([max, self.length].min)
    end
  end
end