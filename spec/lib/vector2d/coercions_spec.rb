# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Coercions do
  subject(:vector) { Vector2d.new(2, 3) }

  describe "#coerce" do
    it "returns the other operand as a vector, followed by itself" do
      expect(vector.coerce(4)).to eq([Vector2d.new(4, 4), vector])
    end

    it "makes a vector the right hand operand of a scalar" do
      expect(2 * vector).to eq(Vector2d.new(4, 6))
    end

    it "retains the operand order of the original expression" do
      expect(10 - vector).to eq(Vector2d.new(8, 7))
    end

    context "when the other operand isn't parseable" do
      it "raises a TypeError" do
        expect { vector.coerce(Object.new) }.to(
          raise_error(TypeError, "Object can't be coerced into Vector2d")
        )
      end
    end

    context "when the other operand is complex" do
      it "raises a TypeError" do
        expect { vector.coerce(Complex(1, 2)) }.to(
          raise_error(TypeError, "Complex can't be coerced into Vector2d")
        )
      end
    end

    context "when a complex number is the left hand operand" do
      it "raises a TypeError" do
        expect { Complex(1, 2) * vector }.to(
          raise_error(TypeError, "Complex can't be coerced into Vector2d")
        )
      end
    end
  end

  describe "#inspect" do
    it "renders a string representation" do
      expect(vector.inspect).to eq("Vector2d(2,3)")
    end

    context "when the vector is a subclass" do
      subject(:vector) { SubVector.new(2, 3) }

      before { stub_const("SubVector", Class.new(Vector2d)) }

      it "renders the name of the subclass" do
        expect(vector.inspect).to eq("SubVector(2,3)")
      end
    end
  end

  describe "#to_a" do
    it "returns an array" do
      expect(vector.to_a).to eq([2, 3])
    end
  end

  describe "#to_f_vector" do
    subject { vector.to_f_vector }

    its(:x) { is_expected.to be_a(Float) }
    its(:y) { is_expected.to be_a(Float) }
  end

  describe "#to_hash" do
    it "returns a hash" do
      expect(vector.to_hash).to eq(x: 2, y: 3)
    end
  end

  describe "#to_i_vector" do
    subject { vector.to_i_vector }

    let(:vector) { Vector2d.new(2.0, 3.0) }

    its(:x) { is_expected.to be_a(Integer) }
    its(:y) { is_expected.to be_a(Integer) }
  end

  describe "#to_s" do
    context "when fixnum" do
      subject(:vector) { Vector2d.new(2, 3) }

      it "renders a string" do
        expect(vector.to_s).to eq("2x3")
      end
    end

    context "when float" do
      subject(:vector) { Vector2d.new(2.0, 3.0) }

      it "renders a string" do
        expect(vector.to_s).to eq("2.0x3.0")
      end
    end
  end
end
