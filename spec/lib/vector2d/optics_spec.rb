# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Optics do
  subject(:vector) { Vector2d.new(2, 3) }

  describe "#reflect" do
    let(:normal) { Vector2d.new(1, 2) }

    it "reflects the vector about the line perpendicular to the normal" do
      expect(vector.reflect(Vector2d.new(0, 1))).to eq(Vector2d.new(2.0, -3.0))
    end

    it "normalizes the normal" do
      expect(vector.reflect(Vector2d.new(0, 5)))
        .to eq(vector.reflect(Vector2d.new(0, 1)))
    end

    it "reverses a vector parallel to the normal" do
      expect(vector.reflect(vector).distance(vector.reverse))
        .to be_within(1e-12).of(0.0)
    end

    it "preserves the length of the vector" do
      expect(vector.reflect(normal).length).to be_within(1e-12).of(vector.length)
    end

    it "returns the original vector when applied twice" do
      expect(vector.reflect(normal).reflect(normal).distance(vector))
        .to be_within(1e-12).of(0.0)
    end

    it "coerces the argument" do
      expect(vector.reflect([0, 1])).to eq(vector.reflect(Vector2d.new(0, 1)))
    end

    it "returns the vector unchanged for a zero vector" do
      expect(vector.reflect(Vector2d.new(0, 0))).to eq(vector)
    end

    it "ignores the component types of a zero normal" do
      expect(vector.reflect(Vector2d.new(0, 0)))
        .to eql(vector.reflect(Vector2d.new(0.0, 0.0)))
    end

    describe "the components" do
      subject { vector.reflect(normal) }

      its(:x) { is_expected.to be_a(Float) }
      its(:y) { is_expected.to be_a(Float) }
    end

    describe "the components of a reflection off a zero vector" do
      subject { vector.reflect(Vector2d.new(0, 0)) }

      its(:x) { is_expected.to be_a(Float) }
      its(:y) { is_expected.to be_a(Float) }
    end
  end

  describe "#refract" do
    subject(:vector) { Vector2d.new(1, -1).normalize }

    let(:normal) { Vector2d.new(0, 1) }

    it "bends the vector towards the normal" do
      expect(vector.refract(normal, 0.5))
        .to eq(Vector2d.new(0.35355339059327373, -0.9354143466934853))
    end

    it "normalizes the normal" do
      expect(vector.refract(Vector2d.new(0, 5), 0.5))
        .to eq(vector.refract(normal, 0.5))
    end

    it "leaves the vector on course for a ratio of one" do
      expect(vector.refract(normal, 1.0).distance(vector))
        .to be_within(1e-12).of(0.0)
    end

    it "preserves the length of a unit vector" do
      expect(vector.refract(normal, 0.5).length).to be_within(1e-12).of(1.0)
    end

    it "keeps the vector on the far side of the surface" do
      expect(vector.refract(normal, 0.5).dot_product(normal)).to be_negative
    end

    it "coerces the normal" do
      expect(vector.refract([0, 1], 0.5)).to eq(vector.refract(normal, 0.5))
    end

    context "when the ratio is an integer" do
      it "refracts as with the equivalent float" do
        expect(vector.refract(normal, 1)).to eq(vector.refract(normal, 1.0))
      end
    end

    context "when past the critical angle" do
      subject { vector.refract(normal, 2.0) }

      it "returns the zero vector" do
        expect(vector.refract(normal, 2.0)).to eq(Vector2d.new(0.0, 0.0))
      end

      its(:x) { is_expected.to be_a(Float) }
      its(:y) { is_expected.to be_a(Float) }
    end

    context "with a grazing angle" do
      subject(:vector) { Vector2d.new(1, -0.0001).normalize }

      it "refracts without reaching total internal reflection" do
        expect(vector.refract(normal, 0.5).length).to be_within(1e-12).of(1.0)
      end
    end

    context "with a zero normal" do
      it "returns the vector unchanged" do
        expect(vector.refract(Vector2d.new(0, 0), 0.5)).to eq(vector)
      end

      it "ignores the component types of the normal" do
        expect(vector.refract(Vector2d.new(0, 0), 0.5))
          .to eql(vector.refract(Vector2d.new(0.0, 0.0), 0.5))
      end

      it "raises before checking the normal for a complex ratio" do
        expect { vector.refract(Vector2d.new(0, 0), Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end

    context "with integer coordinates" do
      subject { Vector2d.new(0, -1).refract(normal, 0.5) }

      its(:x) { is_expected.to be_a(Float) }
      its(:y) { is_expected.to be_a(Float) }
    end

    context "with a complex ratio" do
      it "raises an error" do
        expect { vector.refract(normal, Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end

    context "with a vector ratio" do
      it "raises an error" do
        expect { vector.refract(normal, Vector2d.new(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: Vector2d(1,2)")
        )
      end
    end
  end
end
