# frozen_string_literal: true

class Vector2d
  module Coercions
    # Implements Ruby's coercion protocol, so a vector can be the right
    # hand operand of a scalar.
    #
    #   2 * Vector2d(3, 4) # => Vector2d(6,8)
    #
    def coerce(other)
      [to_vector(other), self]
    end

    # Renders vector as a pretty string.
    #
    #   Vector2d(2, 3).inspect # => "Vector2d(2,3)"
    #
    def inspect
      "#{self.class}(#{x},#{y})"
    end

    # Converts vector to array.
    #
    #   Vector2d(2, 3).to_a # => [2,3]
    #
    def to_a
      [x, y]
    end

    # Converts vector to hash.
    #
    #   Vector2d(2, 3).to_hash # => {x: 2, y: 3}
    #
    def to_hash
      { x: x, y: y }
    end

    # Converts vector to fixnums.
    #
    #   Vector2d(2.0, 3.0).to_i_vector # => Vector2d(2,3)
    #
    def to_i_vector
      self.class.new(x.to_i, y.to_i)
    end

    # Converts vector to floats.
    #
    #   Vector2d(2, 3).to_f_vector # => Vector2d(2.0,3.0)
    #
    def to_f_vector
      self.class.new(x.to_f, y.to_f)
    end

    # Converts vector to string.
    #
    #   Vector2d.new(150, 100).to_s # => "150x100"
    #
    def to_s
      "#{x}x#{y}"
    end

    private

    # Parses anything Vector2d.parse accepts into a vector.
    def to_vector(other)
      case other
      when Vector2d, Array, Numeric, String, Hash
        Vector2d.parse(other)
      else
        raise TypeError, "#{other.class} can't be coerced into #{self.class}"
      end
    end
  end
end
