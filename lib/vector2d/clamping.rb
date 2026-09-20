# frozen_string_literal: true

class Vector2d
  # Bounding a vector, by its coordinates or by its length.
  module Clamping
    # Clamps the vector between two others, one axis at a time. The
    # bounds are coerced, so scalars work too.
    #
    #   vector = Vector2d(2, 8)
    #   vector.clamp(Vector2d(3, 3), Vector2d(6, 6)) # => Vector2d(3,6)
    #   vector.clamp(3, 6)                           # => Vector2d(3,6)
    #
    # The bounds can also be given as a single range, which may be
    # beginless or endless to clamp only one side.
    #
    #   vector.clamp(3..6) # => Vector2d(3,6)
    #   vector.clamp(..6)  # => Vector2d(2,6)
    #   vector.clamp(3..)  # => Vector2d(3,8)
    #
    # The range must not exclude its end, as with Comparable#clamp.
    #
    #   vector.clamp(3...6) # => ArgumentError
    #
    def clamp(min, max = nil)
      min_v, max_v = clamp_bounds(min, max)
      build(
        x.clamp(Range.new(min_v&.x, max_v&.x)),
        y.clamp(Range.new(min_v&.y, max_v&.y))
      )
    end

    # Clamps the length of the vector, scaling it down if it is longer
    # than max. A single argument is a maximum.
    #
    #   vector = Vector2d(2.0, 3.0)
    #   vector.clamp_length(5.0) # => Vector2d(2.0, 3.0)
    #   vector.clamp_length(1.0) # => Vector2d(0.5547.., 0.8320..)
    #
    # Given two, the length is clamped between them, scaling the vector
    # up if it is shorter than min.
    #
    #   vector.clamp_length(5.0, 10.0) # => Vector2d(2.7735.., 4.1602..)
    #   vector.clamp_length(1.0, 10.0) # => Vector2d(2.0, 3.0)
    #
    # The bounds can also be given as a single range, which may be
    # beginless or endless to clamp only one side, as in #clamp.
    #
    #   vector.clamp_length(5.0..10.0) # => Vector2d(2.7735.., 4.1602..)
    #   vector.clamp_length(..1.0)     # => Vector2d(0.5547.., 0.8320..)
    #   vector.clamp_length(5.0..)     # => Vector2d(2.7735.., 4.1602..)
    #
    # The range must not exclude its end, as with Comparable#clamp.
    #
    #   vector.clamp_length(5.0...10.0) # => ArgumentError
    #
    # The zero vector has no direction, and is returned unchanged. It
    # can't be scaled up to a minimum length.
    #
    #   Vector2d(0, 0).clamp_length(1.0)      # => Vector2d(0,0)
    #   Vector2d(0, 0).clamp_length(1.0, 2.0) # => Vector2d(0,0)
    #
    # Lengths can't be negative, and min can't exceed max.
    #
    #   Vector2d(2, 3).clamp_length(-1.0)     # => ArgumentError
    #   Vector2d(2, 3).clamp_length(4.0, 2.0) # => ArgumentError
    #
    def clamp_length(min, max = nil)
      min_length, max_length = clamp_length_bounds(min, max)
      resize(length.clamp(Range.new(min_length, max_length)))
    end

    private

    def clamp_bounds(min, max)
      if min.is_a?(Range)
        return range_bounds(min, max)
               .map { |bound| bound && coerce_vector(bound) }
      end

      raise ArgumentError, "wrong number of arguments (given 1, expected 2)" if max.nil?

      [coerce_vector(min), coerce_vector(max)]
    end

    # Splits the bounds of #clamp_length into a [min, max] pair, either
    # of which can be nil for a one sided clamp. A single argument is a
    # maximum, so a minimum on its own has to come from a range.
    def clamp_length_bounds(min, max)
      return range_length_bounds(min, max) if min.is_a?(Range)
      return [nil, length_bound(min, "max")] if max.nil?

      [length_bound(min, "min"), length_bound(max, "max")]
    end

    def range_length_bounds(range, max)
      range_bounds(range, max).zip(%w[min max]).map do |bound, name|
        bound && length_bound(bound, name)
      end
    end

    # Validates one end of a length clamp. Lengths are never negative.
    def length_bound(value, name)
      value = coordinate(value)
      raise ArgumentError, "negative #{name} length: #{value}" if value.negative?

      value
    end

    # Splits the range form of #clamp and #clamp_length into its two
    # ends, either of which can be nil.
    def range_bounds(range, max)
      raise ArgumentError, "wrong number of arguments (given 2, expected 1)" unless max.nil?
      raise ArgumentError, "cannot clamp with an exclusive range" if range.exclude_end?

      [range.begin, range.end]
    end
  end
end
