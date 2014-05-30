# encoding: utf-8

class Vector2d
  module Properties
    # Angle of this vector
    def angle
      Math.atan2(y, x)
    end

    # Aspect ratio of vector
    def aspect_ratio
      (x.to_f / y.to_f).abs
    end

    # Length of vector
    def length
      Math.sqrt(length_squared)
    end

    # Returns the length of this vector before square root. Allows for a faster check.
    def length_squared
      x * x + y * y
    end

    # Is this a normalized vector?
    def normalized?
      self.length.to_f == 1.0
    end
  end
end