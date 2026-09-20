# frozen_string_literal: true

class Vector2d
  # The permissive constructor. Everything Vector2d.parse accepts is
  # recognized here, and turned into two coordinates the class builds a
  # vector from. It is a module rather than a plain class method, so a
  # subclass parses into its own kind.
  module Parsing
    # Matches a single coordinate in a string, with an optional sign and
    # an optional fractional part.
    COORDINATE_EXPRESSION = /[+-]?(?:\d+(?:\.\d+)?|\.\d+)/

    # Matches the string form of a vector, "150x100" or "150,100".
    # Whitespace is insignificant, the separator is case insensitive, and
    # either coordinate can be left out to mean zero.
    STRING_EXPRESSION = /
      \A\s*(#{COORDINATE_EXPRESSION})?\s*[x,]\s*(#{COORDINATE_EXPRESSION})?\s*\z
    /xi

    # Stands in for an omitted second argument to .parse, so an explicit
    # nil can be rejected as a coordinate.
    NO_ARGUMENT = Object.new.freeze

    private_constant :COORDINATE_EXPRESSION, :STRING_EXPRESSION, :NO_ARGUMENT

    # Parses a vector out of any of the forms below, and is the
    # permissive counterpart to .new, which takes exactly two
    # coordinates. Vector2d() is shorthand for this method.
    #
    #   Vector2d.parse(150, 100)
    #   Vector2d.parse(150.0, 100.0)
    #   Vector2d.parse("150x100")
    #   Vector2d.parse("150.0x100.0")
    #   Vector2d.parse([150,100])
    #   Vector2d.parse({x: 150, y: 100})
    #   Vector2d.parse({"x" => 150.0, "y" => 100.0})
    #   Vector2d.parse(Vector2d(150, 100))
    #   Vector2d.parse(Vector[150, 100])
    #   Vector2d.parse(Matrix[[150], [100]])
    #
    # Strings are either "150x100" or "150,100", optionally signed and
    # case insensitive. Coordinates keep their type, so "150x100" gives
    # integers and "150.0x100" gives a float and an integer. An omitted
    # coordinate is zero, as in "x100".
    #
    #   Vector2d.parse("-150X100") # => Vector2d(-150,100)
    #   Vector2d.parse("150, 100") # => Vector2d(150,100)
    #   Vector2d.parse("x100")     # => Vector2d(0,100)
    #
    # Raises ArgumentError unless both coordinates resolve to real
    # numbers. Complex numbers are not coordinates, and are rejected.
    #
    #   Vector2d.parse(150, nil)         # => ArgumentError
    #   Vector2d.parse(Complex(1, 2), 3) # => ArgumentError
    #
    # @param arg [Vector2d, Array, String, Hash, Integer, Float,
    #   Rational, BigDecimal, ::Vector, ::Matrix] the vector, in any of
    #   the forms above, or its x coordinate
    # @param second_arg [Integer, Float, Rational, BigDecimal]
    #   the y coordinate, when the first argument is the x coordinate
    # @return [Vector2d] a vector of this class, unless the argument is
    #   already a vector, which is returned as it is
    def parse(arg, second_arg = NO_ARGUMENT)
      return parse_single_arg(arg) if NO_ARGUMENT.equal?(second_arg)

      build(coordinate(arg), coordinate(second_arg))
    end

    private

    def parse_single_arg(arg)
      return arg if arg.is_a?(Vector2d)
      return parse_array(arg) if arg.is_a?(Array)
      return parse_str(arg) if arg.is_a?(String)
      return parse_hash(arg) if arg.is_a?(Hash)
      return parse_vector(arg) if MatrixInterop.vector?(arg)
      return parse_matrix(arg) if MatrixInterop.matrix?(arg)

      value = coordinate(arg)
      build(value, value)
    end

    def parse_array(array)
      case array.length
      when 1 then parse_single_arg(array.first)
      when 2 then build(coordinate(array[0]), coordinate(array[1]))
      else
        raise ArgumentError, "expected 1 or 2 coordinates, got #{array.length}"
      end
    end

    def parse_hash(hash)
      build(coordinate(hash[:x] || hash["x"]),
            coordinate(hash[:y] || hash["y"]))
    end

    def parse_matrix(matrix)
      shape = [matrix.row_count, matrix.column_count]
      unless [[2, 1], [1, 2]].include?(shape)
        raise ArgumentError,
              "expected a 2x1 or 1x2 matrix, got #{shape.join('x')}"
      end

      values = matrix.to_a.flatten
      build(coordinate(values[0]), coordinate(values[1]))
    end

    def parse_vector(vector)
      raise ArgumentError, "expected 2 coordinates, got #{vector.size}" unless vector.size == 2

      build(coordinate(vector[0]), coordinate(vector[1]))
    end

    def parse_str(str)
      match = STRING_EXPRESSION.match(str)
      raise ArgumentError, "not a valid string input: #{str.inspect}" unless match

      build(string_coordinate(match[1]), string_coordinate(match[2]))
    end

    def string_coordinate(value)
      return 0 if value.nil?

      value.include?(".") ? value.to_f : value.to_i
    end
  end
end
