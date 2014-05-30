# encoding: utf-8

# Vector2d allows for easy handling of two-dimensionals coordinates and vectors.
# It's very flexible, most methods accepts arguments as strings, arrays, hashes
# or Vector2d objects.
class Vector2d
  class << self
    # Calculates cross product of two vectors
    def cross_product(vector1, vector2)
      vector1.x * vector2.y - vector1.y * vector2.x
    end

    # Calculates dot product of two vectors
    def dot_product(vector1, vector2)
      vector1.x * vector2.x + vector1.y * vector2.y
    end

    # Calculates angle between two vectors in radians
    def angle_between(vector1, vector2)
      one = vector1.normalized? ? vector1 : vector1.normalize
      two = vector2.normalized? ? vector2 : vector2.normalize
      Math.acos(self.dot_product(one, two))
    end
  end

  # X axis
  attr_accessor :x
  # Y axis
  attr_accessor :y

  # Creates a new vector.
  # The following examples are all valid:
  #
  #   Vector2d.new(150, 100)
  #   Vector2d.new(150.0, 100.0)
  #   Vector2d.new("150x100")
  #   Vector2d.new("150.0x100.0")
  #   Vector2d.new([150,100})
  #   Vector2d.new({:x => 150, :y => 100})
  #   Vector2d.new({"x" => 150.0, "y" => 100.0})
  #   Vector2d.new(Vector2d.new(150, 100))
  def initialize(*args)
    args.flatten!

    if args.length == 2
      @x, @y = *args
    elsif args.length == 1
      case args.first
      when Vector2d
        @x, @y = args.first.x, args.first.y
      when Numeric
        @x = args.first
        @y = args.first
      when Hash
        if args.first.has_key?(:x)
          @x = args.first[:x]
        elsif args.first.has_key?("x")
          @x = args.first["x"]
        end
        if args.first.has_key?(:y)
          @y = args.first[:y]
        elsif args.first.has_key?("y")
          @y = args.first["y"]
        end
      when /^[\s]*[\d\.]*[\s]*x[\s]*[\d\.]*[\s]*$/
        @x, @y = args.first.split("x").map(&:to_f)
      else
        raise ArgumentError, "unsupported argument type #{args.first.class}"
      end
    else
      raise ArgumentError, "wrong number of arguments (#{args.length} for 1..2)"
    end

    unless @x.is_a?(Numeric) && @y.is_a?(Numeric)
      raise ArgumentError, "unsupported argument type (#{@x.class}, #{@y.class})"
    end

    @x, @y = [@x, @y].map(&:to_f)
  end

  # Compares two vectors.
  def ==(comp)
    comp.x == @x && comp.y == y
  end

  # Returns a string representation of the vector.
  #
  # Example:
  #   Vector2d.new( 150, 100 ).to_s  # "150x100"
  def to_s
    "#{@x}x#{@y}"
  end

  # Length of vector
  def length
    Math.sqrt(length_squared)
  end

  # Returns the length of this vector before square root. Allows for a faster check.
  def length_squared
    @x * @x + @y * @y
  end

  # Set new length.
  def length=(new_length)
    v = self * (new_length/length)
    @x, @y = v.x, v.y
  end

  # Returns a normalized (length = 1.0) version of the vector.
  def normalize
    self.dup.normalize!
  end

  # In-place form of Vector2d.normalize.
  def normalize!
    self.length = 1.0
    self
  end

  def normalized?
    self.length == 1.0
  end

  # Rounds coordinates to nearest integer.
  def round
    self.dup.round!
  end

  # In-place form of Vector2d.round.
  def round!
    @x, @y = @x.round, @y.round
    self
  end

  # Returns the aspect ratio of the vector.
  def aspect_ratio
    (@x/@y).abs
  end

  # Multiply vectors. If args is a single Numeric, both axis will be multiplied.
  def *(*vector_or_number)
    v = Vector2d::new(vector_or_number)
    Vector2d.new(@x*v.x, @y*v.y)
  end

  # Divide vectors. If args is a single Numeric, both axis will be divided.
  def /(*vector_or_number)
    v = Vector2d::new(vector_or_number)
    Vector2d.new(@x/v.x, @y/v.y)
  end

  # Add vectors. If args is a single Numeric, it will be added to both axis.
  def +(*vector_or_number)
    v = Vector2d::new(vector_or_number)
    Vector2d.new(@x+v.x, @y+v.y)
  end

  # Subtract vectors. If args is a single Numeric, it will be subtracted from both axis.
  def -(*vector_or_number)
    v = Vector2d::new(vector_or_number)
    Vector2d.new(@x-v.x, @y-v.y)
  end

  # Return a new vector perpendicular to this one
  def perpendicular
    Vector2d.new(-@y, @x)
  end

  # Calculates distance between two vectors
  def distance(vector2)
    Math.sqrt(distance_sq(vector2))
  end

  # Calculate squared distance between vectors. Faster than standard distance.
  # param vector2 The other vector.
  # returns the squared distance between the vectors.
  def distance_sq(vector2)
    dx = vector2.x - @x
    dy = vector2.y - @y
    dx * dx + dy * dy
  end

  # Angle of this vector
  def angle
    Math.atan2(@y, @x)
  end

  # Sets the length under the given value. Nothing is done if
  # the vector is already shorter.
  def truncate(max)
    self.length = [max, self.length].min
    self
  end

  # Makes the vector face the opposite way.
  def reverse
    @x = -@x
    @y = -@y
    self
  end

  # Dot product of this vector and another vector
  def dot_product(vector2)
    self.class.dot_product(self, vector2)
  end

  # Cross product of this vector and another vector
  def cross_product(vector2)
    self.class.cross_product(self, vector2)
  end

  # Angle in radians between this vector and another
  def angle_between(vector2)
    self.class.angle_between(self, vector2)
  end

  # Constrain/expand so that both coordinates fit within (the square implied by) another vector.
  # This is useful for resizing images to fit a certain size while keeping aspect ratio.
  #
  # == Examples
  #
  #   my_image = Vector2d.new("320x200")  # Creates a new vector object
  #   my_image.constrain_both(100)        # Returns a new vector: x=100, y=63
  #   my_image.constrain_both(150, 50)    # Returns a new vector: x=80, y=50
  #   my_image.constrain_both("150x50")   # Equal to constrain_both( 150, 50 )
  #   my_image.constrain_both("x100")     # Returns a new vector: x=160, y=100
  #
  # == Note
  #
  # Either axis will be disregarded if zero or nil (see the last example). This is a feature, not a bug. ;)
  def constrain_both(*vector_or_number)
    scale = Vector2d::new(vector_or_number) / self
    (self * ((scale.y==0||(scale.x>0&&scale.x<scale.y)) ? scale.x : scale.y))
  end

  # Constrain/expand so that one of the coordinates fit within (the square implied by) another vector.
  #
  # == Example
  #
  #   my_image = Vector2d.new("320x200")  # Creates a new vector object
  #   my_image.constrain_one(100, 100)    # Returns a new vector: x=160, y=100
  def constrain_one( *vector_or_number )
    scale = Vector2d::new(vector_or_number) / self
    if (scale.x > 0 && scale.y > 0)
      scale = (scale.x<scale.y) ? scale.y : scale.x
      self * scale
    else
      constrain_both(vector_or_number)
    end
  end

end
