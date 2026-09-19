# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Calculations do
  subject(:vector) { Vector2d.new(2, 3) }

  describe ".cross_product" do
    let(:v1) { Vector2d.new(2, 3) }
    let(:v2) { Vector2d.new(4, 5) }

    it "calculates the cross product between two vectors" do
      expect(Vector2d.cross_product(v1, v2)).to eq(-2.0)
    end
  end

  describe ".dot_product" do
    let(:v1) { Vector2d.new(2, 3) }
    let(:v2) { Vector2d.new(4, 5) }

    it "calculates the dot product between two vectors" do
      expect(Vector2d.dot_product(v1, v2)).to eq(23)
    end
  end

  describe ".angle_to" do
    let(:v1) { Vector2d.new(2, 3) }
    let(:v2) { Vector2d.new(4, 5) }

    it "calculates the angle from one vector to another" do
      expect(Vector2d.angle_to(v1, v2)).to be_within(0.0001).of(-0.0867)
    end

    it "signs the angle by direction of rotation" do
      expect(Vector2d.angle_to(v2, v1)).to be_within(0.0001).of(0.0867)
    end

    it "ignores the magnitude of the vectors" do
      expect(
        Vector2d.angle_to(v1 * 1000, v2 * 0.001)
      ).to be_within(0.0001).of(-0.0867)
    end

    it "returns zero for identical vectors" do
      expect(Vector2d.angle_to(v1, v1)).to eq(0.0)
    end

    it "returns zero for parallel vectors" do
      expect(Vector2d.angle_to(v1, v1 * 2.3)).to eq(0.0)
    end

    it "returns PI for antiparallel vectors" do
      expect(Vector2d.angle_to(v1, v1 * -2.3)).to eq(Math::PI)
    end

    it "returns zero for a zero length vector" do
      expect(Vector2d.angle_to(v1, Vector2d.new(0, 0))).to eq(0.0)
    end

    it "stays within -PI..PI" do
      angles = 360.times.map do |i|
        Vector2d.angle_to(v1, v1.rotate(i * Math::PI / 180))
      end
      expect(angles).to all(be_between(-Math::PI, Math::PI))
    end

    it "handles parallel vectors of any magnitude" do
      angles = 1000.times.map do |i|
        v = Vector2d.new((i + 1) * 0.37, (i + 1) * -1.13)
        Vector2d.angle_to(v, v * ((i % 7) + 1))
      end
      expect(angles).to all(be_within(1e-12).of(0.0))
    end
  end

  describe ".angle_between" do
    let(:v1) { Vector2d.new(2, 3) }
    let(:v2) { Vector2d.new(4, 5) }

    it "calculates the unsigned angle between two vectors" do
      expect(Vector2d.angle_between(v1, v2)).to be_within(0.0001).of(0.0867)
    end

    it "ignores the order of the arguments" do
      expect(Vector2d.angle_between(v2, v1))
        .to eq(Vector2d.angle_between(v1, v2))
    end

    it "ignores the magnitude of the vectors" do
      expect(
        Vector2d.angle_between(v1 * 1000, v2 * 0.001)
      ).to be_within(0.0001).of(0.0867)
    end

    it "returns zero for parallel vectors" do
      expect(Vector2d.angle_between(v1, v1 * 2.3)).to eq(0.0)
    end

    it "returns PI for antiparallel vectors" do
      expect(Vector2d.angle_between(v1, v1 * -2.3)).to eq(Math::PI)
    end

    it "returns zero for a zero length vector" do
      expect(Vector2d.angle_between(v1, Vector2d.new(0, 0))).to eq(0.0)
    end

    it "stays within 0..PI" do
      angles = 360.times.map do |i|
        Vector2d.angle_between(v1, v1.rotate(i * Math::PI / 180))
      end
      expect(angles).to all(be_between(0, Math::PI))
    end
  end

  describe "*" do
    context "with vector" do
      subject(:vector) { Vector2d.new(2, 3) * Vector2d.new(3, 4) }

      it "multiplies the vectors" do
        expect(vector).to eq(Vector2d.new(6, 12))
      end
    end

    context "with number" do
      subject(:vector) { Vector2d.new(2, 3) * 3 }

      it "multiplies both members" do
        expect(vector).to eq(Vector2d.new(6, 9))
      end
    end
  end

  describe "/" do
    context "with vector" do
      subject(:vector) { Vector2d.new(6, 12) / Vector2d.new(2, 3) }

      it "divides the vectors" do
        expect(vector).to eq(Vector2d.new(3, 4))
      end
    end

    context "with number" do
      subject(:vector) { Vector2d.new(6, 12) / 3 }

      it "divides both members" do
        expect(vector).to eq(Vector2d.new(2, 4))
      end
    end
  end

  describe "+" do
    context "with vector" do
      subject(:vector) { Vector2d.new(2, 3) + Vector2d.new(3, 4) }

      it "adds the vectors" do
        expect(vector).to eq(Vector2d.new(5, 7))
      end
    end

    context "with number" do
      subject(:vector) { Vector2d.new(2, 3) + 2 }

      it "adds to both members" do
        expect(vector).to eq(Vector2d.new(4, 5))
      end
    end
  end

  describe "-" do
    context "with vector" do
      subject(:vector) { Vector2d.new(3, 5) - Vector2d.new(1, 2) }

      it "subtracts the vectors" do
        expect(vector).to eq(Vector2d.new(2, 3))
      end
    end

    context "with number" do
      subject(:vector) { Vector2d.new(2, 3) - 2 }

      it "subtracts from both members" do
        expect(vector).to eq(Vector2d.new(0, 1))
      end
    end
  end

  describe "-@" do
    it "reverses the vector" do
      expect(-Vector2d.new(2, 3)).to eq(Vector2d.new(-2, -3))
    end

    it "is the same as #reverse" do
      expect(-vector).to eq(vector.reverse)
    end

    it "returns the original vector when applied twice" do
      expect(-(-vector)).to eq(vector)
    end
  end

  describe "+@" do
    it "returns the vector unchanged" do
      expect(+Vector2d.new(2, 3)).to eq(Vector2d.new(2, 3))
    end

    it "returns the same object" do
      expect(+vector).to be(vector)
    end
  end

  describe "#cross_product" do
    let(:comp) { Vector2d.new(3, 4) }

    it "calulates the cross product" do
      expect(
        vector.cross_product(comp)
      ).to eq(Vector2d.cross_product(vector, comp))
    end
  end

  describe "#distance" do
    let(:comp) { Vector2d.new(3, 4) }

    it "returns the distance between two vectors" do
      expect(vector.distance(comp)).to be_within(0.0001).of(1.4142)
    end
  end

  describe "#distance_squared" do
    let(:comp) { Vector2d.new(5, 6) }

    it "returns the squared distance between two vectors" do
      expect(vector.distance_squared(comp)).to eq(18)
    end
  end

  describe "#squared_distance" do
    let(:comp) { Vector2d.new(5, 6) }

    it "is an alias of #distance_squared" do
      expect(vector.squared_distance(comp)).to eq(18)
    end
  end

  describe "#manhattan_distance" do
    let(:comp) { Vector2d.new(5, 7) }

    it "returns the sum of the absolute differences" do
      expect(vector.manhattan_distance(comp)).to eq(7)
    end

    it "is symmetric" do
      expect(comp.manhattan_distance(vector))
        .to eq(vector.manhattan_distance(comp))
    end

    it "returns zero for the same vector" do
      expect(vector.manhattan_distance(vector)).to eq(0)
    end

    it "coerces the argument" do
      expect(vector.manhattan_distance([5, 7])).to eq(7)
    end
  end

  describe "#chebyshev_distance" do
    let(:comp) { Vector2d.new(5, 7) }

    it "returns the largest absolute difference" do
      expect(vector.chebyshev_distance(comp)).to eq(4)
    end

    it "is symmetric" do
      expect(comp.chebyshev_distance(vector))
        .to eq(vector.chebyshev_distance(comp))
    end

    it "returns zero for the same vector" do
      expect(vector.chebyshev_distance(vector)).to eq(0)
    end

    it "coerces the argument" do
      expect(vector.chebyshev_distance([5, 7])).to eq(4)
    end
  end

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

  describe "#dot_product" do
    let(:comp) { Vector2d.new(3, 4) }

    it "calulates the dot product" do
      expect(vector.dot_product(comp)).to eq(Vector2d.dot_product(vector, comp))
    end
  end

  describe "#angle_to" do
    let(:comp) { Vector2d.new(3, 4) }

    it "calculates the angle to the other vector" do
      expect(
        vector.angle_to(comp)
      ).to eq(Vector2d.angle_to(vector, comp))
    end

    it "coerces the argument" do
      expect(vector.angle_to([3, 4])).to eq(vector.angle_to(comp))
    end
  end

  describe "#angle_between" do
    let(:comp) { Vector2d.new(3, 4) }

    it "calculates the angle between vectors" do
      expect(
        vector.angle_between(comp)
      ).to eq(Vector2d.angle_between(vector, comp))
    end

    it "coerces the argument" do
      expect(vector.angle_between([3, 4])).to eq(vector.angle_between(comp))
    end
  end

  describe "#project" do
    let(:comp) { Vector2d.new(4, 0) }

    it "returns the component along the other vector" do
      expect(vector.project(comp)).to eq(Vector2d.new(2.0, 0.0))
    end

    it "ignores the magnitude of the other vector" do
      expect(vector.project(comp * 10)).to eq(vector.project(comp))
    end

    it "ignores the direction of the other vector" do
      expect(vector.project(comp.reverse)).to eq(vector.project(comp))
    end

    it "is parallel to the other vector" do
      expect(vector.project(comp).angle_between(comp)).to eq(0.0)
    end

    it "coerces the argument" do
      expect(vector.project([4, 0])).to eq(vector.project(comp))
    end

    it "returns the zero vector when projecting onto a zero vector" do
      expect(vector.project(Vector2d.new(0, 0))).to eq(Vector2d.new(0, 0))
    end

    it "returns the zero vector when projecting a zero vector" do
      expect(Vector2d.new(0, 0).project(comp)).to eq(Vector2d.new(0, 0))
    end

    describe "the components" do
      subject { vector.project(comp) }

      its(:x) { is_expected.to be_a(Float) }
      its(:y) { is_expected.to be_a(Float) }
    end

    describe "the components of a projection onto a zero vector" do
      subject { vector.project(Vector2d.new(0, 0)) }

      its(:x) { is_expected.to be_a(Float) }
      its(:y) { is_expected.to be_a(Float) }
    end
  end

  describe "#reject" do
    let(:comp) { Vector2d.new(4, 0) }

    it "returns the component perpendicular to the other vector" do
      expect(vector.reject(comp)).to eq(Vector2d.new(0.0, 3.0))
    end

    it "is what remains when the projection is subtracted" do
      expect(vector.project(comp) + vector.reject(comp)).to eq(vector)
    end

    it "coerces the argument" do
      expect(vector.reject([4, 0])).to eq(vector.reject(comp))
    end

    it "returns the vector unchanged for a zero vector" do
      expect(vector.reject(Vector2d.new(0, 0))).to eq(vector)
    end
  end

  describe "#scalar_projection" do
    let(:comp) { Vector2d.new(4, 0) }

    it "returns the signed length of the projection" do
      expect(vector.scalar_projection(comp)).to eq(2.0)
    end

    it "is negative when the vectors point in opposite directions" do
      expect(vector.scalar_projection(comp.reverse)).to eq(-2.0)
    end

    it "ignores the magnitude of the other vector" do
      expect(vector.scalar_projection(comp * 10)).to eq(2.0)
    end

    it "matches the length of the vector projection" do
      expect(vector.scalar_projection(comp).abs)
        .to be_within(1e-12).of(vector.project(comp).length)
    end

    it "coerces the argument" do
      expect(vector.scalar_projection([4, 0])).to eq(2.0)
    end

    it "returns zero for a zero vector" do
      expect(vector.scalar_projection(Vector2d.new(0, 0))).to eq(0.0)
    end
  end

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
  end
end
