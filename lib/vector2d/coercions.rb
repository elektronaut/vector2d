# encoding: utf-8

class Vector2d
  module Coercions
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

    def inspect
      "Vector2d(#{x},#{y})"
    end

    # Convert to array
    def to_a
      [x, y]
    end

    # Convert to integer
    def to_i
      self.class.new(x.to_i, y.to_i)
    end

    # Convert to float
    def to_f
      self.class.new(x.to_f, y.to_f)
    end

    # Convert to string
    #
    #   Vector2d.new(150, 100).to_s # => "150x100"
    def to_s
      "#{x}x#{y}"
    end
  end
end