# frozen_string_literal: true

require "spec_helper"
require "matrix"

describe Vector2d::MatrixInterop do
  subject(:vector) { Vector2d.new(2, 3) }

  let(:rotation) { Matrix[[0, -1], [1, 0]] }

  describe ".matrix?" do
    it "recognizes a matrix" do
      expect(described_class).to be_matrix(rotation)
    end

    it "doesn't recognize anything else" do
      expect(described_class).not_to be_matrix([[0, -1], [1, 0]])
    end
  end

  describe ".vector?" do
    it "recognizes a vector" do
      expect(described_class).to be_vector(Vector[2, 3])
    end

    it "doesn't recognize anything else" do
      expect(described_class).not_to be_vector(vector)
    end
  end

  describe "#coerce" do
    it "returns the matrix first, followed by itself as a vector" do
      expect(vector.coerce(rotation)).to eq([rotation, Vector[2, 3]])
    end

    it "makes a vector the right hand operand of a matrix" do
      expect(rotation * vector).to eq(Vector[-3, 2])
    end

    it "makes a vector the left hand operand of a Vector" do
      expect(Vector[1, 2] + vector).to eq(Vector2d.new(3, 5))
    end

    context "when the other operand isn't a matrix" do
      it "falls back to parsing the operand" do
        expect(vector.coerce(4)).to eq([Vector2d.new(4, 4), vector])
      end
    end
  end

  describe "#to_matrix" do
    it "returns a column matrix" do
      expect(vector.to_matrix).to eq(Matrix[[2], [3]])
    end
  end

  describe "#to_vector" do
    it "returns a vector" do
      expect(vector.to_vector).to eq(Vector[2, 3])
    end
  end

  describe "#transform" do
    it "multiplies the matrix by itself as a column" do
      expect(vector.transform(rotation)).to eq(Vector2d.new(-3, 2))
    end

    context "when the argument isn't a matrix" do
      it "raises a TypeError" do
        expect { vector.transform([[0, -1], [1, 0]]) }.to(
          raise_error(TypeError, "Array is not a Matrix")
        )
      end
    end

    context "when the matrix doesn't have two columns" do
      it "raises a dimension mismatch" do
        expect { vector.transform(Matrix[[1, 2, 3], [4, 5, 6]]) }.to(
          raise_error(ExceptionForMatrix::ErrDimensionMismatch)
        )
      end
    end

    context "when the matrix holds a complex" do
      it "raises an error" do
        expect { vector.transform(Matrix[[Complex(0, 1), 0], [0, 1]]) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (0+2i)")
        )
      end
    end
  end
end
