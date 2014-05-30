# encoding: utf-8

class Vector2d
  module Calculations
    module ClassMethods
      # Calculates cross product of two vectors
      def cross_product(vector1, vector2)
        vector1.x * vector2.y - vector1.y * vector2.x
      end

      # Calculates dot product of two vectors
      def dot_product(vector1, vector2)
        vector1.x * vector2.x + vector1.y * vector2.y
      end

      # Calculates angle between two vectors in radians
      def angle_between(vector1, vector2)
        one = vector1.normalized? ? vector1 : vector1.normalize
        two = vector2.normalized? ? vector2 : vector2.normalize
        Math.acos(self.dot_product(one, two))
      end
    end

    # Multiplies vectors
    def *(other)
      v, _ = coerce(other)
      self.class.new(x * v.x, y * v.y)
    end

    # Divides vectors
    def /(other)
      v, _ = coerce(other)
      self.class.new(x / v.x, y / v.y)
    end

    # Adds vectors
    def +(other)
      v, _ = coerce(other)
      self.class.new(x + v.x, y + v.y)
    end

    # Subtracts vectors
    def -(other)
      v, _ = coerce(other)
      self.class.new(x - v.x, y - v.y)
    end

    # Calculates the distance between two vectors
    def distance(other)
      Math.sqrt(distance_sq(other))
    end

    # Calculate squared distance between vectors
    def distance_sq(other)
      v, _ = coerce(other)
      dx = v.x - x
      dy = v.y - y
      dx * dx + dy * dy
    end

    # Dot product of this vector and another vector
    def dot_product(other)
      v, _ = coerce(other)
      self.class.dot_product(self, v)
    end

    # Cross product of this vector and another vector
    def cross_product(other)
      v, _ = coerce(other)
      self.class.cross_product(self, v)
    end

    # Angle in radians between this vector and another vector
    def angle_between(other)
      v, _ = coerce(other)
      self.class.angle_between(self, v)
    end
  end
end