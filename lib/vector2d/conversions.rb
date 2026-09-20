# frozen_string_literal: true

class Vector2d
  # Conversions to and from other Ruby objects, including the coercion
  # protocol and pattern matching. Conversions to the standard library
  # Matrix and Vector are in Vector2d::MatrixInterop.
  module Conversions
    # Implements Ruby's coercion protocol, so a vector can be the right
    # hand operand of a scalar.
    #
    #   2 * Vector2d(3, 4) # => Vector2d(6,8)
    #
    # The operand is built through #build, so a subclass is the result
    # on either side of the operator.
    #
    # Matrices are coerced the other way around, see
    # Vector2d::MatrixInterop#coerce.
    #
    # @!macro coercible
    # @return [Array(self, self)] the coerced operand and this vector
    def coerce(other)
      v = coerce_vector(other)
      [build(v.x, v.y), self]
    end

    # Returns the components as an array, so a vector can be matched
    # against an array pattern.
    #
    #   Vector2d(3, 4).deconstruct # => [3,4]
    #
    #   case Vector2d(3, 4)
    #   in [0, 0] then :origin
    #   in [Integer => a, Integer => b] then a + b
    #   end # => 7
    #
    # @return [Array<Integer, Float, Rational, BigDecimal>] the [x, y] pair
    def deconstruct
      to_a
    end

    # Returns the components as a hash, so a vector can be matched
    # against a hash pattern. Both components are always returned,
    # whichever keys the pattern asks for.
    #
    #   Vector2d(3, 4).deconstruct_keys([:x]) # => {x: 3, y: 4}
    #
    #   case Vector2d(0, 4)
    #   in {x: 0} then :on_y_axis
    #   in {y: 0} then :on_x_axis
    #   end # => :on_y_axis
    #
    # @param _keys [Array<Symbol>, nil] ignored, both components are
    #   always returned
    # @return [Hash{Symbol => Integer, Float, Rational, BigDecimal}]
    #   the x and y coordinates
    def deconstruct_keys(_keys)
      to_hash
    end

    # Renders vector as a pretty string.
    #
    #   Vector2d(2, 3).inspect # => "Vector2d(2,3)"
    #
    # @return [String]
    def inspect
      "#{self.class}(#{x},#{y})"
    end

    # Converts vector to array.
    #
    #   Vector2d(2, 3).to_a # => [2,3]
    #
    # @return [Array<Integer, Float, Rational, BigDecimal>] the [x, y] pair
    def to_a
      [x, y]
    end

    # Converts vector to hash.
    #
    #   Vector2d(2, 3).to_hash # => {x: 2, y: 3}
    #
    # @return [Hash{Symbol => Integer, Float, Rational, BigDecimal}]
    #   the x and y coordinates
    def to_hash
      { x: x, y: y }
    end

    # Converts the coordinates to integers. The result is still a
    # vector of this class, unlike #to_vector, which converts to the
    # standard library Vector.
    #
    #   Vector2d(2.0, 3.0).to_i_vector # => Vector2d(2,3)
    #
    # @return [self]
    def to_i_vector
      build(x.to_i, y.to_i)
    end

    # Converts the coordinates to floats. As with #to_i_vector, the
    # result is a vector of this class.
    #
    #   Vector2d(2, 3).to_f_vector # => Vector2d(2.0,3.0)
    #
    # @return [self]
    def to_f_vector
      build(x.to_f, y.to_f)
    end

    # Converts vector to string.
    #
    #   Vector2d.new(150, 100).to_s # => "150x100"
    #
    # @return [String]
    def to_s
      "#{x}x#{y}"
    end

    private

    # Parses anything Vector2d.parse accepts into a vector. A vector is
    # returned as it is.
    def coerce_vector(other)
      return other if other.is_a?(Vector2d)
      return Vector2d.parse(other) if parseable?(other)

      raise TypeError, "#{other.class} can't be coerced into #{self.class}"
    end

    # Can the object be parsed into a vector? Complex numbers are
    # Numeric, but they are not coordinates.
    def parseable?(other)
      case other
      when Vector2d, Array, String, Hash then true
      when Numeric then other.real?
      else MatrixInterop.vector?(other) || MatrixInterop.matrix?(other)
      end
    end
  end
end
