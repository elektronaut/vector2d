# frozen_string_literal: true

class Vector2d
  # Coordinate validation, shared by the class methods that parse input
  # and by the constructor.
  module Coordinates
    module_function

    # Returns the value if it is a valid coordinate, raises
    # ArgumentError otherwise. Coordinates are real numbers, so Complex
    # is rejected along with everything outside Numeric.
    #
    # @param value [Object] the value to validate
    # @return [Integer, Float, Rational, BigDecimal] the value
    def coordinate(value)
      return value if value.is_a?(Float) || value.is_a?(Integer)
      raise ArgumentError, "not a valid coordinate: #{value.inspect}" unless value.is_a?(Numeric) && value.real?

      value
    end
  end
end
