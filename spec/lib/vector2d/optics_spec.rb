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
end
