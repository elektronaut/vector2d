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

  describe "#deconstruct" do
    it "returns an array" do
      expect(vector.deconstruct).to eq([2, 3])
    end
  end

  describe "#deconstruct_keys" do
    it "returns a hash" do
      expect(vector.deconstruct_keys(nil)).to eq(x: 2, y: 3)
    end

    context "when only one key is requested" do
      it "returns both components" do
        expect(vector.deconstruct_keys([:x])).to eq(x: 2, y: 3)
      end
    end
  end

  describe "pattern matching" do
    def classify(vector)
      case vector
      in [0, 0] then :origin
      in [Integer => a, Integer => b] then a + b
      end
    end

    def axis_of(vector)
      case vector
      in { x: 0, y: 0 } then :origin
      in { x: 0 } then :on_y_axis
      in { y: 0 } then :on_x_axis
      else :off_axis
      end
    end

    def orientation_of(vector)
      case vector
      in [x, y] if x < y then :portrait
      in [x, y] if x > y then :landscape
      else :square
      end
    end

    def contains?(vector, value)
      case vector
      in [*, ^value, *] then true
      else false
      end
    end

    it "destructures into an array" do
      vector => [x, y]

      expect([x, y]).to eq([2, 3])
    end

    it "destructures into keys" do
      vector => { x:, y: }

      expect([x, y]).to eq([2, 3])
    end

    it "binds the components of an array pattern" do
      expect(classify(vector)).to eq(5)
    end

    it "matches a hash pattern" do
      expect(axis_of(vector)).to eq(:off_axis)
    end

    it "matches a guarded pattern" do
      expect(orientation_of(vector)).to eq(:portrait)
    end

    it "matches a find pattern" do
      expect(contains?(vector, 3)).to be(true)
    end

    it "doesn't match a find pattern on a missing component" do
      expect(contains?(vector, 4)).to be(false)
    end

    it "destructures a vector nested in an array" do
      [Vector2d.new(0, 0), vector] => [[0, 0], [x, y]]

      expect([x, y]).to eq([2, 3])
    end

    it "destructures a vector nested in a hash" do
      { size: vector } => { size: { x:, y: } }

      expect([x, y]).to eq([2, 3])
    end

    context "when the vector is the origin" do
      subject(:vector) { Vector2d.new(0, 0) }

      it "matches the leading array pattern" do
        expect(classify(vector)).to eq(:origin)
      end

      it "matches the leading hash pattern" do
        expect(axis_of(vector)).to eq(:origin)
      end
    end

    context "when the vector is on an axis" do
      subject(:vector) { Vector2d.new(0, 3) }

      it "matches on the partial hash pattern" do
        expect(axis_of(vector)).to eq(:on_y_axis)
      end
    end

    context "when the components are floats" do
      subject(:vector) { Vector2d.new(2.0, 3.0) }

      it "raises NoMatchingPatternError" do
        expect { classify(vector) }.to raise_error(NoMatchingPatternError)
      end

      it "still matches an untyped pattern" do
        expect(orientation_of(vector)).to eq(:portrait)
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

  describe "#to_polar" do
    it "returns the length first" do
      expect(vector.to_polar.first).to be_within(0.0001).of(3.6055)
    end

    it "returns the angle second" do
      expect(vector.to_polar.last).to be_within(0.0001).of(0.9827)
    end

    it "is the inverse of Vector2d.from_angle" do
      length, angle = vector.to_polar

      expect(Vector2d.from_angle(angle, length))
        .to eq(Vector2d.new(2.0, 3.0))
    end

    context "with the zero vector" do
      let(:vector) { Vector2d.new(0, 0) }

      it "returns zero length and angle" do
        expect(vector.to_polar).to eq([0.0, 0.0])
      end
    end
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
