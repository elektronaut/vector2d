# frozen_string_literal: true

class Vector2d
  module Calculations
    include Contracts

    module ClassMethods
      include Contracts

      # Calculates cross product of two vectors.
      #
      #   v1 = Vector2d(2, 1)
      #   v2 = Vector2d(2, 3)
      #   Vector2d.cross_product(v1, v2) # => 4
      #
      Contract Vector2d, Vector2d => Num
      def cross_product(vector1, vector2)
        (vector1.x * vector2.y) - (vector1.y * vector2.x)
      end

      # Calculates dot product of two vectors.
      #
      #   v1 = Vector2d(2, 1)
      #   v2 = Vector2d(2, 3)
      #   Vector2d.dot_product(v1, v2) # => 10
      #
      Contract Vector2d, Vector2d => Num
      def dot_product(vector1, vector2)
        (vector1.x * vector2.x) + (vector1.y * vector2.y)
      end

      # Calculates angle between two vectors in radians.
      #
      #   v1 = Vector2d(2, 3)
      #   v2 = Vector2d(4, 5)
      #   Vector2d.angle_between(v1, v2) # => 0.0867..
      #
      Contract Vector2d, Vector2d => Num
      def angle_between(vector1, vector2)
        one = vector1.normalized? ? vector1 : vector1.normalize
        two = vector2.normalized? ? vector2 : vector2.normalize
        Math.acos(dot_product(one, two))
      end
    end

    # Multiplies vectors.
    #
    #   Vector2d(1, 2) * Vector2d(2, 3) # => Vector2d(2, 6)
    #   Vector2d(1, 2) * 2              # => Vector2d(2, 4)
    #
    Contract VectorLike => Vector2d
    def *(other)
      calculate_each(:*, other)
    end

    # Divides vectors.
    #
    #   Vector2d(4, 2) / Vector2d(2, 1) # => Vector2d(2, 2)
    #   Vector2d(4, 2) / 2              # => Vector2d(2, 1)
    #
    Contract VectorLike => Vector2d
    def /(other)
      calculate_each(:/, other)
    end

    # Adds vectors.
    #
    #   Vector2d(1, 2) + Vector2d(2, 3) # => Vector2d(3, 5)
    #   Vector2d(1, 2) + 2              # => Vector2d(3, 4)
    #
    Contract VectorLike => Vector2d
    def +(other)
      calculate_each(:+, other)
    end

    # Subtracts vectors.
    #
    #   Vector2d(2, 3) - Vector2d(2, 1) # => Vector2d(0, 2)
    #   Vector2d(4, 3) - 1              # => Vector2d(3, 2)
    #
    Contract VectorLike => Vector2d
    def -(other)
      calculate_each(:-, other)
    end

    # Calculates the distance between two vectors.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(5, 6)
    #   v1.distance(v2) # => 1.4142..
    #
    Contract VectorLike => Num
    def distance(other)
      Math.sqrt(squared_distance(other))
    end

    # Calculate squared distance between vectors.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(5, 6)
    #   v1.distance_squared(v2) # => 18
    #
    Contract VectorLike => Num
    def squared_distance(other)
      v, = coerce(other)
      dx = v.x - x
      dy = v.y - y
      (dx * dx) + (dy * dy)
    end

    # Dot product of this vector and another vector.
    #
    #   v1 = Vector2d(2, 1)
    #   v2 = Vector2d(2, 3)
    #   v1.dot_product(v2) # => 10
    #
    Contract VectorLike => Num
    def dot_product(other)
      v, = coerce(other)
      self.class.dot_product(self, v)
    end

    # Cross product of this vector and another vector.
    #
    #   v1 = Vector2d(2, 1)
    #   v2 = Vector2d(2, 3)
    #   v1.cross_product(v2) # => 4
    #
    Contract VectorLike => Num
    def cross_product(other)
      v, = coerce(other)
      self.class.cross_product(self, v)
    end

    # Angle in radians between this vector and another vector.
    #
    #   v1 = Vector2d(2, 3)
    #   v2 = Vector2d(4, 5)
    #   v1.angle_between(v2) # => 0.0867..
    #
    Contract VectorLike => Num
    def angle_between(other)
      v, = coerce(other)
      self.class.angle_between(self, v)
    end

    private

    def calculate_each(method, other)
      v, = coerce(other)
      self.class.new(
        x.send(method, v.x),
        y.send(method, v.y)
      )
    end
  end
end
