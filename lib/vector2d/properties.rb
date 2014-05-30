# encoding: utf-8

class Vector2d
  module Properties
    # Angle of vector.
    #
    #   Vector(2, 3).angle # => 0.9827..
    #
    def angle
      Math.atan2(y, x)
    end

    # Aspect ratio of vector.
    #
    #   Vector(2, 3).aspect_ratio # => 0.6667..
    #
    def aspect_ratio
      (x.to_f / y.to_f).abs
    end

    # Length of vector.
    #
    #   Vector(2, 3).length # => 3.6055..
    #
    def length
      Math.sqrt(squared_length)
    end

    # Squared length of vector.
    #
    #   Vector(2, 3).squared_length # => 13
    #
    def squared_length
      x * x + y * y
    end

    # Is this a normalized vector?
    #
    #   Vector(0, 1).normalized? # => true
    #   Vector(2, 3).normalized? # => false
    #
    def normalized?
      self.length.to_f == 1.0
    end
  end
end