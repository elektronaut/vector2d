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
end
