# frozen_string_literal: true

require "contracts"

class Vector2d
  include Contracts

  VectorLike = Or[
    [Num, Num],
    { x: Num, y: Num },
    { "x" => Num, "y" => Num },
    Num,
    String,
    Vector2d
  ]
end

require "vector2d/calculations"
require "vector2d/coercions"
require "vector2d/fitting"
require "vector2d/properties"
require "vector2d/transformations"
require "vector2d/version"

class Vector2d
  extend Vector2d::Calculations::ClassMethods
  include Vector2d::Calculations
  include Vector2d::Coercions
  include Vector2d::Fitting
  include Vector2d::Properties
  include Vector2d::Transformations

  class << self
    # Creates a new vector.
    # The following examples are all valid:
    #
    #   Vector2d.parse(150, 100)
    #   Vector2d.parse(150.0, 100.0)
    #   Vector2d.parse("150x100")
    #   Vector2d.parse("150.0x100.0")
    #   Vector2d.parse([150,100})
    #   Vector2d.parse({x: 150, y: 100})
    #   Vector2d.parse({"x" => 150.0, "y" => 100.0})
    #   Vector2d.parse(Vector2d(150, 100))
    Contract VectorLike, Maybe[Num] => Vector2d
    def parse(arg, second_arg = nil)
      if second_arg.nil?
        parse_single_arg(arg)
      else
        new(arg, second_arg)
      end
    end

    private

    Contract VectorLike => Vector2d
    def parse_single_arg(arg)
      return arg if arg.is_a?(Vector2d)
      return parse(*arg) if arg.is_a?(Array)
      return parse_str(arg) if arg.is_a?(String)
      return parse_hash(arg.dup) if arg.is_a?(Hash)

      new(arg, arg)
    end

    Contract Hash => Vector2d
    def parse_hash(hash)
      hash[:x] ||= hash["x"] if hash.key?("x")
      hash[:y] ||= hash["y"] if hash.key?("y")
      new(hash[:x], hash[:y])
    end

    Contract String => Vector2d
    def parse_str(str)
      raise ArgumentError, "not a valid string input" unless /^\s*[\d.]*\s*x\s*[\d.]*\s*$/.match?(str)

      x, y = str.split("x")
      new(x.to_f, y.to_f)
    end
  end

  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  # Compares two vectors
  #
  #   Vector2d(2, 3) == Vector2d(2, 3) # => true
  #   Vector2d(2, 3) == Vector2d(1, 0) # => false
  #
  Contract Vector2d => Bool
  def ==(other)
    other.x == x && other.y == y
  end
end

# Instantiates a Vector2d
#
#   Vector2d(2, 3) # => Vector2d(2,3)
#
def Vector2d(*args)
  Vector2d.parse(*args)
end
