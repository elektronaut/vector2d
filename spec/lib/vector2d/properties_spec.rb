# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Properties do
  subject(:vector) { Vector2d.new(2, 3) }

  describe "#angle" do
    it "returns the angle" do
      expect(vector.angle).to be_within(0.0001).of(0.9827)
    end
  end

  describe "#area" do
    it "multiplies the coordinates" do
      expect(vector.area).to eq(6)
    end

    it "is never negative" do
      expect(Vector2d.new(-2, 3).area).to eq(6)
    end

    it "is zero without width or height" do
      expect(Vector2d.new(2, 0).area).to eq(0)
    end
  end

  describe "#aspect_ratio" do
    it "returns the aspect_ratio" do
      expect(vector.aspect_ratio).to be_within(0.0001).of(0.6667)
    end

    context "when y is zero" do
      let(:vector) { Vector2d.new(2, 0) }

      it "raises an ArgumentError" do
        expect { vector.aspect_ratio }
          .to raise_error(ArgumentError,
                          "Vector2d(2,0) has no aspect ratio, y is zero")
      end
    end

    context "with the zero vector" do
      let(:vector) { Vector2d.new(0, 0) }

      it "raises an ArgumentError" do
        expect { vector.aspect_ratio }
          .to raise_error(ArgumentError,
                          "the zero vector has no aspect ratio")
      end
    end
  end

  describe "#landscape?" do
    subject { vector.landscape? }

    context "when the vector is wider than it is tall" do
      let(:vector) { Vector2d.new(3, 2) }

      it { is_expected.to be(true) }
    end

    context "when the vector is taller than it is wide" do
      let(:vector) { Vector2d.new(2, 3) }

      it { is_expected.to be(false) }
    end

    context "when the vector is square" do
      let(:vector) { Vector2d.new(2, 2) }

      it { is_expected.to be(false) }
    end

    context "when the coordinates are negative" do
      let(:vector) { Vector2d.new(-3, -2) }

      it { is_expected.to be(true) }
    end
  end

  describe "#portrait?" do
    subject { vector.portrait? }

    context "when the vector is taller than it is wide" do
      let(:vector) { Vector2d.new(2, 3) }

      it { is_expected.to be(true) }
    end

    context "when the vector is wider than it is tall" do
      let(:vector) { Vector2d.new(3, 2) }

      it { is_expected.to be(false) }
    end

    context "when the vector is square" do
      let(:vector) { Vector2d.new(2, 2) }

      it { is_expected.to be(false) }
    end

    context "when the coordinates are negative" do
      let(:vector) { Vector2d.new(-2, -3) }

      it { is_expected.to be(true) }
    end
  end

  describe "#square?" do
    subject { vector.square? }

    context "when the coordinates are equal" do
      let(:vector) { Vector2d.new(2, 2) }

      it { is_expected.to be(true) }
    end

    context "when the coordinates differ" do
      let(:vector) { Vector2d.new(2, 3) }

      it { is_expected.to be(false) }
    end

    context "when the coordinates differ only in sign" do
      let(:vector) { Vector2d.new(-2, 2) }

      it { is_expected.to be(true) }
    end

    context "with the zero vector" do
      let(:vector) { Vector2d.new(0, 0) }

      it { is_expected.to be(true) }
    end
  end

  describe "the shape predicates" do
    it "are exclusive" do
      [Vector2d.new(3, 2), Vector2d.new(2, 3), Vector2d.new(2, 2),
       Vector2d.new(0, 0)].each do |v|
        expect([v.landscape?, v.portrait?, v.square?].count(true)).to eq(1)
      end
    end
  end

  describe "#length" do
    it "calculates the length" do
      expect(vector.length).to be_within(0.0001).of(3.6055)
    end
  end

  describe "#magnitude" do
    it "is an alias of #length" do
      expect(vector.magnitude).to be_within(0.0001).of(3.6055)
    end
  end

  describe "#norm" do
    it "is an alias of #length" do
      expect(vector.norm).to be_within(0.0001).of(3.6055)
    end
  end

  describe "#length_squared" do
    it "calculates the squared length" do
      expect(vector.length_squared).to eq(13)
    end
  end

  describe "#squared_length" do
    it "is an alias of #length_squared" do
      expect(vector.squared_length).to eq(13)
    end
  end

  describe "#zero?" do
    subject { vector.zero? }

    context "when vector is the zero vector" do
      let(:vector) { Vector2d.new(0, 0) }

      it { is_expected.to be(true) }
    end

    context "when vector isn't the zero vector" do
      let(:vector) { Vector2d.new(2, 3) }

      it { is_expected.to be(false) }
    end
  end

  describe "#approx_zero?" do
    subject { vector.approx_zero? }

    context "when vector is the zero vector" do
      let(:vector) { Vector2d.new(0, 0) }

      it { is_expected.to be(true) }
    end

    context "when vector is a rounding error away from zero" do
      let(:vector) { Vector2d.new(1e-17, 0) }

      it { is_expected.to be(true) }
    end

    context "when vector is small but not that small" do
      let(:vector) { Vector2d.new(1e-15, 0) }

      it { is_expected.to be(false) }
    end

    context "when vector isn't the zero vector" do
      it { is_expected.to be(false) }
    end

    context "with a tolerance" do
      it "takes it as an absolute length" do
        expect(Vector2d.new(0.2, 0)).to be_approx_zero(0.5)
      end

      it "is false outside the tolerance" do
        expect(Vector2d.new(0.6, 0)).not_to be_approx_zero(0.5)
      end

      it "raises an error on a complex tolerance" do
        expect { vector.approx_zero?(Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end
  end

  describe "#approx_equal?" do
    subject { vector.approx_equal?(other) }

    context "when the vectors are equal" do
      let(:other) { Vector2d.new(2, 3) }

      it { is_expected.to be(true) }
    end

    context "when the vectors differ by a rounding error" do
      let(:vector) { Vector2d.new(0.1, 0.2) + Vector2d.new(0.2, 0.4) }
      let(:other) { Vector2d.new(0.3, 0.6) }

      it { is_expected.to be(true) }

      it "is more than #== accepts" do
        expect(vector).not_to eq(other)
      end
    end

    context "when the vectors differ" do
      let(:other) { Vector2d.new(2, 4) }

      it { is_expected.to be(false) }
    end

    context "when the other vector is coercible" do
      let(:other) { [2, 3] }

      it { is_expected.to be(true) }
    end

    it "is symmetric" do
      other = Vector2d.new(0.1, 0.2) + Vector2d.new(0.2, 0.4)

      expect(Vector2d.new(0.3, 0.6)).to be_approx_equal(other)
    end

    it "scales the tolerance with the magnitudes" do
      big = Vector2d.new(1e8, 2e8)

      expect(big).to be_approx_equal(big.rotate(2 * Math::PI))
    end

    it "doesn't accept the same drift at unit scale" do
      expect(Vector2d.new(1, 2))
        .not_to be_approx_equal(Vector2d.new(1, 2 + 5.5e-8))
    end

    context "with a tolerance" do
      it "takes it as an absolute distance" do
        expect(vector).to be_approx_equal(Vector2d.new(2, 4), 1.5)
      end

      it "is false outside the tolerance" do
        expect(vector).not_to be_approx_equal(Vector2d.new(2, 4), 0.5)
      end

      it "includes the tolerance itself" do
        expect(vector).to be_approx_equal(Vector2d.new(2, 4), 1.0)
      end

      it "raises an error on a complex tolerance" do
        expect { vector.approx_equal?(vector, Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end
  end

  describe "#finite?" do
    subject { vector.finite? }

    context "when both coordinates are finite" do
      it { is_expected.to be(true) }
    end

    context "when x is infinite" do
      let(:vector) { Vector2d.new(Float::INFINITY, 3) }

      it { is_expected.to be(false) }
    end

    context "when y is infinite" do
      let(:vector) { Vector2d.new(2, -Float::INFINITY) }

      it { is_expected.to be(false) }
    end

    context "when a coordinate is NaN" do
      let(:vector) { Vector2d.new(2, Float::NAN) }

      it { is_expected.to be(false) }
    end
  end

  describe "#nan?" do
    subject { vector.nan? }

    context "when neither coordinate is NaN" do
      it { is_expected.to be(false) }
    end

    context "when x is NaN" do
      let(:vector) { Vector2d.new(Float::NAN, 3) }

      it { is_expected.to be(true) }
    end

    context "when y is NaN" do
      let(:vector) { Vector2d.new(2, Float::NAN) }

      it { is_expected.to be(true) }
    end

    context "when a coordinate is infinite" do
      let(:vector) { Vector2d.new(2, Float::INFINITY) }

      it { is_expected.to be(false) }
    end
  end

  describe "#normalized?" do
    subject { vector.normalized? }

    context "when vector is normalized" do
      let(:vector) { Vector2d.new(2, 3).normalize }

      it { is_expected.to be(true) }
    end

    context "when vector isn't normalized" do
      let(:vector) { Vector2d.new(2, 3) }

      it { is_expected.to be(false) }
    end

    context "when vector is barely longer than a unit vector" do
      let(:vector) { Vector2d.new(1 + 1e-9, 0) }

      it { is_expected.to be(false) }
    end

    it "is true for any normalized vector" do
      vectors = (1..50).flat_map do |x|
        (1..50).map { |y| Vector2d.new(x, y).normalize }
      end

      expect(vectors).to all(be_normalized)
    end
  end

  describe "#parallel?" do
    subject { vector.parallel?(other) }

    context "when the other vector points the same way" do
      let(:other) { Vector2d.new(4, 6) }

      it { is_expected.to be(true) }
    end

    context "when the other vector points the opposite way" do
      let(:other) { Vector2d.new(-4, -6) }

      it { is_expected.to be(true) }
    end

    context "when the vectors aren't parallel" do
      let(:other) { Vector2d.new(3, 2) }

      it { is_expected.to be(false) }
    end

    context "with the zero vector" do
      let(:other) { Vector2d.new(0, 0) }

      it { is_expected.to be(true) }
    end

    context "when both vectors are zero" do
      let(:vector) { Vector2d.new(0, 0) }
      let(:other) { Vector2d.new(0, 0) }

      it { is_expected.to be(true) }
    end

    it "coerces the argument" do
      expect(vector.parallel?("4x6")).to be(true)
    end

    it "is true for any vector and a multiple of it" do
      vectors = (1..50).flat_map do |x|
        (1..50).map { |y| Vector2d.new(x, y) }
      end

      expect(vectors).to all(satisfy { |v| v.parallel?(v * 3.7) })
    end

    context "with large vectors" do
      let(:vector) { Vector2d.new(1.3e8, 7.7e8) }

      it "is true for a multiple of itself" do
        expect(vector.parallel?(vector * Math::PI)).to be(true)
      end

      it "is false for a vector that is barely off" do
        expect(vector.parallel?(Vector2d.new(1.3e8, 7.7e8 + 1))).to be(false)
      end
    end
  end

  describe "#independent?" do
    subject { vector.independent?(other) }

    context "when the vectors aren't parallel" do
      let(:other) { Vector2d.new(3, 2) }

      it { is_expected.to be(true) }
    end

    context "when the other vector points the same way" do
      let(:other) { Vector2d.new(4, 6) }

      it { is_expected.to be(false) }
    end

    context "with the zero vector" do
      let(:other) { Vector2d.new(0, 0) }

      it { is_expected.to be(false) }
    end
  end

  describe "#opposite?" do
    subject { vector.opposite?(other) }

    context "when the other vector points the opposite way" do
      let(:other) { Vector2d.new(-2, -3) }

      it { is_expected.to be(true) }
    end

    context "when the other vector is a negative multiple" do
      let(:other) { Vector2d.new(-4, -6) }

      it { is_expected.to be(true) }
    end

    context "when the other vector points the same way" do
      let(:other) { Vector2d.new(4, 6) }

      it { is_expected.to be(false) }
    end

    context "when the vectors aren't parallel" do
      let(:other) { Vector2d.new(3, 2) }

      it { is_expected.to be(false) }
    end

    context "when the other vector is perpendicular" do
      let(:other) { Vector2d.new(-3, 2) }

      it { is_expected.to be(false) }
    end

    context "with the zero vector" do
      let(:other) { Vector2d.new(0, 0) }

      it { is_expected.to be(false) }
    end

    context "when the receiver is zero" do
      let(:vector) { Vector2d.new(0, 0) }
      let(:other) { Vector2d.new(2, 3) }

      it { is_expected.to be(false) }
    end

    context "when both vectors are zero" do
      let(:vector) { Vector2d.new(0, 0) }
      let(:other) { Vector2d.new(0, 0) }

      it { is_expected.to be(false) }
    end

    it "coerces the argument" do
      expect(vector.opposite?("-2x-3")).to be(true)
    end

    it "ignores the magnitude of the vectors" do
      expect(vector.opposite?(vector * -1e9)).to be(true)
    end

    it "is true for any vector and a negative multiple of it" do
      vectors = (1..50).flat_map do |x|
        (1..50).map { |y| Vector2d.new(x, y) }
      end

      expect(vectors).to all(satisfy { |v| v.opposite?(v * -3.7) })
    end

    it "is true for the reverse of the vector" do
      expect(vector.opposite?(vector.reverse)).to be(true)
    end

    context "with large vectors" do
      let(:vector) { Vector2d.new(1.3e8, 7.7e8) }

      it "is true for a negative multiple of itself" do
        expect(vector.opposite?(vector * -Math::PI)).to be(true)
      end

      it "is false for a vector that is barely off" do
        expect(vector.opposite?(Vector2d.new(-1.3e8, -7.7e8 - 1))).to be(false)
      end
    end
  end

  describe "#perpendicular_to?" do
    subject { vector.perpendicular_to?(other) }

    context "when the other vector is perpendicular" do
      let(:other) { Vector2d.new(-3, 2) }

      it { is_expected.to be(true) }
    end

    context "when the other vector is perpendicular the other way" do
      let(:other) { Vector2d.new(3, -2) }

      it { is_expected.to be(true) }
    end

    context "when the vectors aren't perpendicular" do
      let(:other) { Vector2d.new(3, 2) }

      it { is_expected.to be(false) }
    end

    context "with the zero vector" do
      let(:other) { Vector2d.new(0, 0) }

      it { is_expected.to be(true) }
    end

    context "when both vectors are zero" do
      let(:vector) { Vector2d.new(0, 0) }
      let(:other) { Vector2d.new(0, 0) }

      it { is_expected.to be(true) }
    end

    it "coerces the argument" do
      expect(vector.perpendicular_to?("-3x2")).to be(true)
    end

    it "is true for any vector rotated a quarter turn" do
      vectors = (1..50).flat_map do |x|
        (1..50).map { |y| Vector2d.new(x, y) }
      end

      expect(vectors)
        .to all(satisfy { |v| v.perpendicular_to?(v.rotate(Math::PI / 2)) })
    end

    context "with large vectors" do
      let(:vector) { Vector2d.new(1.3e8, 7.7e8) }

      it "is true for a quarter turn" do
        expect(vector.perpendicular_to?(vector.rotate(Math::PI / 2)))
          .to be(true)
      end

      it "is false for a vector that is barely off" do
        expect(vector.perpendicular_to?(Vector2d.new(-7.7e8, 1.3e8 + 1)))
          .to be(false)
      end
    end
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
end
