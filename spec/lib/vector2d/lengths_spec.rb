# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Lengths do
  subject(:vector) { Vector2d.new(2, 3) }

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
    subject(:vector) { Vector2d.new(2, 3).squared_length }

    it_behaves_like "a deprecated method", "squared_length", "#length_squared"

    it "returns the squared length, as #length_squared does" do
      expect(vector).to eq(13)
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

  describe "#normalize" do
    subject { vector.normalize }

    its(:x) { is_expected.to be_within(0.0001).of(0.5547) }
    its(:y) { is_expected.to be_within(0.0001).of(0.8320) }

    context "with the zero vector" do
      subject(:vector) { Vector2d.new(0, 0) }

      it "returns the zero vector" do
        expect(vector.normalize).to eq(Vector2d.new(0, 0))
      end
    end
  end

  describe "#resize" do
    subject(:resized) { vector.resize(2.0) }

    it "modifies the vector length" do
      expect(resized.length).to be_within(0.0001).of(2.0)
    end

    it "modifies the x property" do
      expect(resized.x).to be_within(0.0001).of(1.1094)
    end

    it "modifies the y property" do
      expect(resized.y).to be_within(0.0001).of(1.6641)
    end

    context "with the zero vector" do
      subject(:vector) { Vector2d.new(0, 0) }

      it "returns the zero vector" do
        expect(resized).to eq(Vector2d.new(0, 0))
      end
    end

    context "with a float zero vector" do
      subject(:vector) { Vector2d.new(0.0, 0.0) }

      it "returns the zero vector" do
        expect(resized).to eq(Vector2d.new(0.0, 0.0))
      end
    end

    context "with a complex length" do
      it "raises an error" do
        expect { vector.resize(Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end

    context "with a complex length and the zero vector" do
      subject(:vector) { Vector2d.new(0, 0) }

      it "raises an error" do
        expect { vector.resize(Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end

    context "with a negative length" do
      subject(:resized) { vector.resize(-2.0) }

      it "modifies the vector length" do
        expect(resized.length).to be_within(0.0001).of(2.0)
      end

      it "reverses the x property" do
        expect(resized.x).to be_within(0.0001).of(-1.1094)
      end

      it "reverses the y property" do
        expect(resized.y).to be_within(0.0001).of(-1.6641)
      end
    end
  end

  describe "#clamp_length" do
    context "when argument is longer than length" do
      let(:arg) { 5.0 }

      it "does not change the length" do
        expect(vector.clamp_length(arg).length).to be_within(0.0001).of(3.6055)
      end
    end

    context "when argument is shorter than length" do
      let(:arg) { 2.5 }

      it "changes the length" do
        expect(vector.clamp_length(arg).length).to be_within(0.0001).of(arg)
      end
    end

    context "with the zero vector" do
      subject(:vector) { Vector2d.new(0, 0) }

      it "returns the zero vector" do
        expect(vector.clamp_length(5.0)).to eq(Vector2d.new(0, 0))
      end
    end

    context "when argument is negative" do
      it "raises an error" do
        expect { vector.clamp_length(-1.0) }.to raise_error(ArgumentError)
      end
    end

    context "when argument is negative and vector is zero" do
      subject(:vector) { Vector2d.new(0, 0) }

      it "raises an error" do
        expect { vector.clamp_length(-1.0) }.to raise_error(ArgumentError)
      end
    end

    context "when argument is complex" do
      it "raises an error" do
        expect { vector.clamp_length(Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end

    context "when argument is nil" do
      it "raises an error" do
        expect { vector.clamp_length(nil) }.to(
          raise_error(ArgumentError, "not a valid coordinate: nil")
        )
      end
    end

    context "with a minimum and a maximum" do
      it "scales a short vector up to the minimum" do
        expect(vector.clamp_length(5.0, 10.0).length)
          .to be_within(0.0001).of(5.0)
      end

      it "scales a long vector down to the maximum" do
        expect(vector.clamp_length(0.5, 1.0).length)
          .to be_within(0.0001).of(1.0)
      end

      it "leaves a vector between the bounds alone" do
        expect(vector.clamp_length(1.0, 10.0).length)
          .to be_within(0.0001).of(3.6055)
      end

      it "matches the single argument form" do
        expect(vector.clamp_length(0, 2.5)).to eq(vector.clamp_length(2.5))
      end

      it "raises an error when the minimum is negative" do
        expect { vector.clamp_length(-1.0, 10.0) }.to(
          raise_error(ArgumentError, "negative min length: -1.0")
        )
      end

      it "raises an error when the minimum exceeds the maximum" do
        expect { vector.clamp_length(10.0, 1.0) }.to raise_error(ArgumentError)
      end

      it "leaves the zero vector alone" do
        expect(Vector2d.new(0, 0).clamp_length(5.0, 10.0))
          .to eq(Vector2d.new(0, 0))
      end
    end

    context "with a range" do
      it "clamps the length between the bounds" do
        expect(vector.clamp_length(5.0..10.0).length)
          .to be_within(0.0001).of(5.0)
      end

      it "matches the two argument form" do
        expect(vector.clamp_length(5.0..10.0))
          .to eq(vector.clamp_length(5.0, 10.0))
      end

      it "clamps only the upper bound of a beginless range" do
        expect(vector.clamp_length(..1.0).length).to be_within(0.0001).of(1.0)
      end

      it "clamps only the lower bound of an endless range" do
        expect(vector.clamp_length(5.0..).length).to be_within(0.0001).of(5.0)
      end

      it "raises an error with an exclusive range" do
        expect { vector.clamp_length(5.0...10.0) }.to(
          raise_error(ArgumentError, "cannot clamp with an exclusive range")
        )
      end

      it "raises an error with a negative bound" do
        expect { vector.clamp_length(-1.0..10.0) }.to(
          raise_error(ArgumentError, "negative min length: -1.0")
        )
      end

      it "raises an error with a second argument" do
        expect { vector.clamp_length(5.0..10.0, 20.0) }.to(
          raise_error(ArgumentError,
                      "wrong number of arguments (given 2, expected 1)")
        )
      end
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
    subject(:vector) { Vector2d.new(2, 3).squared_distance(Vector2d.new(5, 6)) }

    it_behaves_like "a deprecated method", "squared_distance", "#distance_squared"

    it "returns the squared distance, as #distance_squared does" do
      expect(vector).to eq(18)
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

  describe "#direction_to" do
    subject(:vector) { Vector2d.new(2, 3) }

    let(:comp) { Vector2d.new(5, 7) }

    it "points at the other vector" do
      expect(vector.direction_to(comp).round(3)).to eq(Vector2d.new(0.6, 0.8))
    end

    it "returns a unit vector" do
      expect(vector.direction_to(comp).length).to be_within(0.0001).of(1.0)
    end

    it "matches the normalized difference" do
      expect(vector.direction_to(comp)).to eq((comp - vector).normalize)
    end

    it "points the other way around" do
      expect(vector.direction_to(comp))
        .to eq(comp.direction_to(vector).reverse)
    end

    it "coerces the argument" do
      expect(vector.direction_to([5, 7])).to eq(vector.direction_to(comp))
    end

    context "when the other vector is this one" do
      it "returns the zero vector" do
        expect(vector.direction_to(vector)).to eq(Vector2d.new(0, 0))
      end
    end
  end
end
