# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Interpolation do
  describe "#lerp" do
    subject(:vector) { Vector2d.new(0, 0) }

    let(:comp) { Vector2d.new(10, 20) }

    it "returns this vector at zero" do
      expect(vector.lerp(comp, 0)).to eq(Vector2d.new(0, 0))
    end

    it "returns the other vector at one" do
      expect(vector.lerp(comp, 1)).to eq(Vector2d.new(10, 20))
    end

    it "interpolates between the vectors" do
      expect(vector.lerp(comp, 0.25)).to eq(Vector2d.new(2.5, 5.0))
    end

    it "extrapolates past the other vector" do
      expect(vector.lerp(comp, 2.0)).to eq(Vector2d.new(20.0, 40.0))
    end

    it "extrapolates behind this vector" do
      expect(vector.lerp(comp, -0.5)).to eq(Vector2d.new(-5.0, -10.0))
    end

    it "interpolates from negative coordinates" do
      expect(Vector2d.new(-4, 6).lerp(Vector2d.new(4, -2), 0.5))
        .to eq(Vector2d.new(0.0, 2.0))
    end

    it "coerces the argument" do
      expect(vector.lerp([10, 20], 0.5)).to eq(Vector2d.new(5.0, 10.0))
    end

    context "with a complex amount" do
      it "raises an error" do
        expect { vector.lerp(comp, Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end

    context "with a vector amount" do
      it "raises an error" do
        expect { vector.lerp(comp, Vector2d.new(0.25, 0.5)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: Vector2d(0.25,0.5)")
        )
      end
    end

    context "with a string amount" do
      it "raises an error" do
        expect { vector.lerp(comp, "2x3") }.to(
          raise_error(ArgumentError, 'not a valid coordinate: "2x3"')
        )
      end
    end
  end

  describe "#inverse_lerp" do
    subject(:vector) { Vector2d.new(0, 0) }

    let(:comp) { Vector2d.new(10, 20) }

    it "returns zero at this vector" do
      expect(vector.inverse_lerp(comp, vector)).to eq(0.0)
    end

    it "returns one at the other vector" do
      expect(vector.inverse_lerp(comp, comp)).to eq(1.0)
    end

    it "returns the position of a value on the segment" do
      expect(vector.inverse_lerp(comp, Vector2d.new(2.5, 5.0))).to eq(0.25)
    end

    it "returns a scalar" do
      expect(vector.inverse_lerp(comp, Vector2d.new(2.5, 5.0))).to be_a(Float)
    end

    it "returns a float for integer coordinates" do
      expect(Vector2d.new(0, 0).inverse_lerp(Vector2d.new(4, 0),
                                             Vector2d.new(1, 0))).to eq(0.25)
    end

    it "projects a value off the segment onto the line" do
      expect(vector.inverse_lerp(comp, Vector2d.new(5, 0))).to eq(0.1)
    end

    it "extrapolates past the other vector" do
      expect(vector.inverse_lerp(comp, Vector2d.new(20, 40))).to eq(2.0)
    end

    it "extrapolates behind this vector" do
      expect(vector.inverse_lerp(comp, Vector2d.new(-5, -10))).to eq(-0.5)
    end

    it "inverts #lerp" do
      amount = vector.inverse_lerp(comp, Vector2d.new(2.5, 5.0))

      expect(vector.lerp(comp, amount)).to eq(Vector2d.new(2.5, 5.0))
    end

    it "inverts #lerp from a non-zero origin" do
      v1 = Vector2d.new(-4, 6)
      v2 = Vector2d.new(4, -2)

      expect(v1.inverse_lerp(v2, v1.lerp(v2, 0.3))).to be_within(1e-12).of(0.3)
    end

    it "coerces the other vector" do
      expect(vector.inverse_lerp([10, 20], Vector2d.new(2.5, 5.0))).to eq(0.25)
    end

    it "coerces the value" do
      expect(vector.inverse_lerp(comp, "2.5x5.0")).to eq(0.25)
    end

    context "when the segment has no length along an axis" do
      let(:comp) { Vector2d.new(10, 0) }

      it "returns a finite amount" do
        expect(vector.inverse_lerp(comp, Vector2d.new(2.5, 99))).to eq(0.25)
      end
    end

    context "when the vectors are identical" do
      it "returns zero" do
        expect(vector.inverse_lerp(vector, Vector2d.new(2.5, 5.0))).to eq(0.0)
      end

      it "returns zero for a non-zero vector" do
        expect(comp.inverse_lerp(comp, Vector2d.new(2.5, 5.0))).to eq(0.0)
      end
    end

    context "with an unparseable value" do
      it "raises an error" do
        expect { vector.inverse_lerp(comp, nil) }.to(
          raise_error(TypeError, "NilClass can't be coerced into Vector2d")
        )
      end
    end
  end

  describe "#slerp" do
    subject(:vector) { Vector2d.new(2, 0) }

    let(:comp) { Vector2d.new(0, 4) }

    it "returns this vector at zero" do
      expect(vector.slerp(comp, 0).round(6)).to eq(Vector2d.new(2, 0))
    end

    it "returns the other vector at one" do
      expect(vector.slerp(comp, 1).round(6)).to eq(Vector2d.new(0, 4))
    end

    it "turns halfway around the arc" do
      expect(vector.slerp(comp, 0.5).round(4))
        .to eq(Vector2d.new(2.1213, 2.1213))
    end

    it "interpolates the length" do
      expect(vector.slerp(comp, 0.5).length).to be_within(0.0001).of(3.0)
    end

    it "keeps the length off the straight line #lerp follows" do
      expect(vector.slerp(comp, 0.5).length)
        .to be > vector.lerp(comp, 0.5).length
    end

    it "keeps the angle between the two vectors" do
      expect(vector.angle_between(vector.slerp(comp, 0.5)))
        .to be_within(0.0001).of(Math::PI / 4)
    end

    it "extrapolates past the other vector" do
      expect(vector.slerp(comp, 2.0).angle)
        .to be_within(0.0001).of(Math::PI)
    end

    it "coerces the argument" do
      expect(vector.slerp([0, 4], 0.5)).to eq(vector.slerp(comp, 0.5))
    end

    context "when the vectors point in opposite directions" do
      let(:comp) { Vector2d.new(-2, 0) }

      it "turns counterclockwise" do
        expect(vector.slerp(comp, 0.5).round(6)).to eq(Vector2d.new(0, 2))
      end

      it "reaches the other vector at one" do
        expect(vector.slerp(comp, 1).round(6)).to eq(Vector2d.new(-2, 0))
      end

      it "turns counterclockwise from any direction" do
        expect(Vector2d.new(0, 2).slerp(Vector2d.new(0, -2), 0.5).round(6))
          .to eq(Vector2d.new(-2, 0))
      end
    end

    context "when the vectors point the same way" do
      let(:comp) { Vector2d.new(4, 0) }

      it "only interpolates the length" do
        expect(vector.slerp(comp, 0.5).round(6)).to eq(Vector2d.new(3, 0))
      end
    end

    context "with the zero vector" do
      let(:comp) { Vector2d.new(0, 0) }

      it "interpolates linearly" do
        expect(vector.slerp(comp, 0.25)).to eq(vector.lerp(comp, 0.25))
      end
    end

    context "when this vector is zero" do
      subject(:vector) { Vector2d.new(0, 0) }

      it "interpolates linearly" do
        expect(vector.slerp(comp, 0.25)).to eq(vector.lerp(comp, 0.25))
      end
    end

    context "with a complex amount" do
      it "raises an error" do
        expect { vector.slerp(comp, Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end
  end

  describe "#midpoint" do
    subject(:vector) { Vector2d.new(0, 0) }

    let(:comp) { Vector2d.new(10, 20) }

    it "returns the point halfway between the vectors" do
      expect(vector.midpoint(comp)).to eq(Vector2d.new(5.0, 10.0))
    end

    it "is symmetric" do
      expect(comp.midpoint(vector)).to eq(vector.midpoint(comp))
    end

    it "matches #lerp at one half" do
      expect(vector.midpoint(comp)).to eq(vector.lerp(comp, 0.5))
    end

    it "coerces the argument" do
      expect(vector.midpoint([10, 20])).to eq(Vector2d.new(5.0, 10.0))
    end
  end

  describe "#move_toward" do
    subject(:vector) { Vector2d.new(0, 0) }

    let(:comp) { Vector2d.new(10, 0) }

    it "moves the given distance" do
      expect(vector.move_toward(comp, 2)).to eq(Vector2d.new(2, 0))
    end

    it "moves along the direction to the target" do
      expect(Vector2d.new(2, 3).move_toward(Vector2d.new(5, 7), 2.5).round(3))
        .to eq(Vector2d.new(3.5, 5))
    end

    it "stops at the target" do
      expect(vector.move_toward(comp, 20)).to eq(comp)
    end

    it "stops at the target when the distance is exact" do
      expect(vector.move_toward(comp, 10)).to eq(comp)
    end

    it "moves away from the target with a negative distance" do
      expect(vector.move_toward(comp, -2)).to eq(Vector2d.new(-2, 0))
    end

    it "does not overshoot moving away" do
      expect(vector.move_toward(comp, -20)).to eq(Vector2d.new(-20, 0))
    end

    it "coerces the target" do
      expect(vector.move_toward([10, 0], 2)).to eq(Vector2d.new(2, 0))
    end

    it "converges on the target in steps" do
      stepped = 6.times.reduce(vector) { |v, _| v.move_toward(comp, 2) }

      expect(stepped).to eq(comp)
    end

    context "when the vector is already at the target" do
      it "returns the target" do
        expect(comp.move_toward(comp, 2)).to eq(comp)
      end

      it "returns the target with a negative distance" do
        expect(comp.move_toward(comp, -2)).to eq(comp)
      end
    end

    context "with a complex distance" do
      it "raises an error" do
        expect { vector.move_toward(comp, Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end
  end
end
