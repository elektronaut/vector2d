# frozen_string_literal: true

class Vector2d
  module Coercions
    include Contracts

    Contract VectorLike => [Vector2d, Vector2d]
    def coerce(other)
      case other
      when Vector2d
        [other, self]
      when Array, Numeric, String, Hash
        [Vector2d.parse(other), self]
      else
        raise TypeError, "#{self.class} can't be coerced into #{other.class}"
      end
    end

    # Renders vector as a pretty string.
    #
    #   Vector2d(2, 3).inspect # => "Vector2d(2,3)"
    #
    Contract None => String
    def inspect
      "Vector2d(#{x},#{y})"
    end

    # Converts vector to array.
    #
    #   Vector2d(2, 3).to_a # => [2,3]
    #
    Contract None => [Num, Num]
    def to_a
      [x, y]
    end

    # Converts vector to hash.
    #
    #   Vector2d(2, 3).to_hash # => {x: 2, y: 3}
    #
    Contract None => Hash
    def to_hash
      { x: x, y: y }
    end

    # Converts vector to fixnums.
    #
    #   Vector2d(2.0, 3.0).to_i_vector # => Vector2d(2,3)
    #
    Contract None => Vector2d
    def to_i_vector
      self.class.new(x.to_i, y.to_i)
    end

    # Converts vector to floats.
    #
    #   Vector2d(2, 3).to_f_vector # => Vector2d(2.0,3.0)
    #
    Contract None => Vector2d
    def to_f_vector
      self.class.new(x.to_f, y.to_f)
    end

    # Converts vector to string.
    #
    #   Vector2d.new(150, 100).to_s # => "150x100"
    #
    Contract None => String
    def to_s
      "#{x}x#{y}"
    end
  end
end
