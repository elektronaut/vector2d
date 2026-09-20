# frozen_string_literal: true

class Vector2d
  # The operators. A scalar operand applies to both coordinates.
  # Anything else is coerced into a vector and applied one axis at a
  # time.
  module Arithmetic
    # Multiplies vectors.
    #
    #   Vector2d(1, 2) * Vector2d(2, 3) # => Vector2d(2, 6)
    #   Vector2d(1, 2) * 2              # => Vector2d(2, 4)
    #
    # @!macro coercible
    # @return [self]
    def *(other)
      calculate_each(:*, other)
    end

    # Divides vectors.
    #
    #   Vector2d(4, 2) / Vector2d(2, 1) # => Vector2d(2, 2)
    #   Vector2d(4, 2) / 2              # => Vector2d(2, 1)
    #
    # @!macro coercible
    # @return [self]
    def /(other)
      calculate_each(:/, other)
    end

    # Adds vectors.
    #
    #   Vector2d(1, 2) + Vector2d(2, 3) # => Vector2d(3, 5)
    #   Vector2d(1, 2) + 2              # => Vector2d(3, 4)
    #
    # @!macro coercible
    # @return [self]
    def +(other)
      calculate_each(:+, other)
    end

    # Subtracts vectors.
    #
    #   Vector2d(2, 3) - Vector2d(2, 1) # => Vector2d(0, 2)
    #   Vector2d(4, 3) - 1              # => Vector2d(3, 2)
    #
    # @!macro coercible
    # @return [self]
    def -(other)
      calculate_each(:-, other)
    end

    # Returns the vector reversed.
    #
    #   -Vector2d(2, 3) # => Vector2d(-2,-3)
    #
    # @return [self]
    def -@
      reverse
    end

    # Returns the vector unchanged.
    #
    #   +Vector2d(2, 3) # => Vector2d(2,3)
    #
    # @return [self]
    def +@
      self
    end

    # Reverses the vector.
    #
    #   Vector2d(2, 3).reverse # => Vector2d(-2,-3)
    #
    # @return [self]
    def reverse
      build(-x, -y)
    end

    private

    # Is the value a number both coordinates can be combined with
    # directly? Complex is Numeric, but it is not a coordinate.
    def real_number?(value)
      value.is_a?(Numeric) && value.real?
    end

    def calculate_each(method, other)
      return build(x.send(method, other), y.send(method, other)) if real_number?(other)

      v = coerce_vector(other)
      build(
        x.send(method, v.x),
        y.send(method, v.y)
      )
    end
  end
end
