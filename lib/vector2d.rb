# Vector2d allows for easy handling of two-dimensionals coordinates and vectors.
# It's very flexible, most methods accepts arguments as strings, arrays, hashes
# or Vector2d objects.
class Vector2d

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
		if (args.length == 1)
			if (args[0].kind_of?(String) && args[0].match(/^[\s]*[\d\.]*[\s]*x[\s]*[\d\.]*[\s]*$/))
				args = args[0].split("x")
			elsif args[0].kind_of?(Vector2d)
				args = [args[0].x, args[0].y]
			elsif args[0].kind_of?(Hash)
				args[0] = args[0][:x]  if args[0][:x]
				args[0] = args[0]["x"] if args[0]["x"]
				args[1] = args[0][:y]  if args[0][:y]
				args[1] = args[0]["y"] if args[0]["y"]
			else
				args = [args[0], args[0]]
			end
		end
		@x, @y = args[0].to_f, args[1].to_f
	end

	# Compares two vectors.
	def ==(comp)
		( comp.x == @x && comp.y == y )
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
    (@x * @x) + (@y * @y)
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

  # return a new vector perpendicular to this one
  def perpendicular
    Vector2d.new(-@y, @x)
  end
    
  # distance between two vectors
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
  
  # dot product of two vectors
  def self.dot_product(vector1, vector2)
    one = vector1.normalized? ? vector1 : vector1.normalize
    two = vector2.normalized? ? vector2 : vector2.normalize
    one.x * two.x + one.y * two.y
  end

  # angle between two vectors in radians
  def self.angle_between(vector1, vector2)
    one = vector1.normalized? ? vector1 : vector1.normalize
    two = vector2.normalized? ? vector2 : vector2.normalize
    Math.acos(self.dot_product(one, two))
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
