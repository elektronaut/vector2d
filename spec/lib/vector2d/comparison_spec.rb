# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Comparison do
  subject(:vector) { Vector2d.new(2, 3) }

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

  describe "#perpendicular?" do
    subject { vector.perpendicular?(other) }

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
      expect(vector.perpendicular?("-3x2")).to be(true)
    end

    it "is true for any vector rotated a quarter turn" do
      vectors = (1..50).flat_map do |x|
        (1..50).map { |y| Vector2d.new(x, y) }
      end

      expect(vectors)
        .to all(satisfy { |v| v.perpendicular?(v.rotate(Math::PI / 2)) })
    end

    context "with large vectors" do
      let(:vector) { Vector2d.new(1.3e8, 7.7e8) }

      it "is true for a quarter turn" do
        expect(vector.perpendicular?(vector.rotate(Math::PI / 2)))
          .to be(true)
      end

      it "is false for a vector that is barely off" do
        expect(vector.perpendicular?(Vector2d.new(-7.7e8, 1.3e8 + 1)))
          .to be(false)
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
end
