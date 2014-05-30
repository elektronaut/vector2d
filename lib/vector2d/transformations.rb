# encoding: utf-8

class Vector2d
  module Transformations
    # Returns a normalized (length = 1.0) version of the vector.
    def normalize
      resize(1.0)
    end

    # Return a new vector perpendicular to this one
    def perpendicular
      Vector2d.new(-y, x)
    end

    # Changes magnitude of vector
    def resize(new_length)
      self * (new_length / self.length)
    end

    # Reverses the vector
    def reverse
      self.class.new(-x, -y)
    end

    # Rounds coordinates to nearest integer.
    def round
      self.class.new(x.round, y.round)
    end

    # Sets the length under the given value. Nothing is done if
    # the vector is already shorter.
    def truncate(max)
      resize([max, self.length].min)
    end
  end
end