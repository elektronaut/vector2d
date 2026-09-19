# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Properties do
  subject(:vector) { Vector2d.new(2, 3) }

  describe "#angle" do
    it "returns the angle" do
      expect(vector.angle).to be_within(0.0001).of(0.9827)
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

  describe "#length" do
    it "calculates the length" do
      expect(vector.length).to be_within(0.0001).of(3.6055)
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
