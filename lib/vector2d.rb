# encoding: utf-8

require 'vector2d/calculations'
require 'vector2d/coercions'
require 'vector2d/fitting'
require 'vector2d/properties'
require 'vector2d/transformations'
require 'vector2d/version'

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
    #   Vector2d.parse({:x => 150, :y => 100})
    #   Vector2d.parse({"x" => 150.0, "y" => 100.0})
    #   Vector2d.parse(Vector2d.new(150, 100))
    def parse(arg, second_arg=nil)
      if second_arg.nil?
        parse_single_arg(arg)
      else
        self.new(arg, second_arg)
      end
    end

    private

    def parse_single_arg(arg)
      case arg
      when Vector2d
        arg
      when Array
        self.parse(*arg)
      when String
        parse_str(arg)
      when Hash
        parse_hash(arg.dup)
      else
        self.new(arg, arg)
      end
    end

    def parse_hash(hash)
      hash[:x] ||= hash['x'] if hash.has_key?('x')
      hash[:y] ||= hash['y'] if hash.has_key?('y')
      self.new(hash[:x], hash[:y])
    end

    def parse_str(str)
      if str =~ /^[\s]*[\d\.]*[\s]*x[\s]*[\d\.]*[\s]*$/
        self.new(*str.split("x").map(&:to_f))
      else
        raise ArgumentError, "not a valid string input"
      end
    end
  end

  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  # Compare two vectors
  def ==(comp)
    comp.x == x && comp.y == y
  end
end
