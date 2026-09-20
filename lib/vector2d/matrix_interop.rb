# frozen_string_literal: true

class Vector2d
  # Interoperability with the Matrix and Vector classes from the
  # standard library.
  #
  # The matrix library is a bundled gem, and is only loaded when a
  # conversion needs it. Nothing here loads it on its own, so it has to
  # be in the Gemfile of applications using these methods.
  module MatrixInterop
    class << self
      # Is the object a Matrix?
      #
      # @param object [Object] any object
      # @return [Boolean]
      def matrix?(object)
        defined?(::Matrix) && object.is_a?(::Matrix)
      end

      # Is the object a Vector?
      #
      # @param object [Object] any object
      # @return [Boolean]
      def vector?(object)
        defined?(::Vector) && object.is_a?(::Vector)
      end
    end

    # Implements Ruby's coercion protocol for matrices, so a vector can
    # be the right hand operand of a matrix. The result is a Vector, as
    # the matrix is the receiver of the operation.
    #
    #   Matrix[[0, -1], [1, 0]] * Vector2d(3, 4) # => Vector[-4, 3]
    #
    # Use #transform to get a Vector2d back.
    #
    # Vectors are coerced the other way around, as the two dimensional
    # vector is the more specific type.
    #
    #   Vector[1, 2] + Vector2d(3, 4) # => Vector2d(4,6)
    #
    # @!macro coercible
    # @return [Array(::Matrix, ::Vector), Array(self, self)] the other
    #   operand and this vector, converted to a Vector when the other
    #   operand is a Matrix
    def coerce(other)
      return [other, to_vector] if MatrixInterop.matrix?(other)

      super
    end

    # Converts vector to a 2x1 column Matrix from the standard library,
    # the same shape Vector#to_matrix returns.
    #
    #   Vector2d(2, 3).to_matrix # => Matrix[[2], [3]]
    #
    # @return [::Matrix] a 2x1 column matrix
    def to_matrix
      require "matrix"
      ::Matrix[[x], [y]]
    end

    # Converts vector to a Vector from the standard library. This is
    # the only to_* method that leaves the class behind, #to_f_vector
    # and #to_i_vector return a vector of this class.
    #
    #   Vector2d(2, 3).to_vector # => Vector[2, 3]
    #
    # @return [::Vector]
    def to_vector
      require "matrix"
      ::Vector[x, y]
    end

    # Multiplies a 2x2 Matrix by this vector, treating the vector as a
    # column. Unlike coercion, this keeps the class of the receiver.
    #
    #   Vector2d(3, 4).transform(Matrix[[0, -1], [1, 0]])
    #   # => Vector2d(-4,3)
    #
    # Raises TypeError unless the argument is a Matrix, and
    # ErrDimensionMismatch unless it has two columns.
    #
    # @param matrix [::Matrix] a matrix with two columns
    # @return [self]
    def transform(matrix)
      raise TypeError, "#{matrix.class} is not a Matrix" unless MatrixInterop.matrix?(matrix)

      result = matrix * to_vector
      build(result[0], result[1])
    end
  end
end
