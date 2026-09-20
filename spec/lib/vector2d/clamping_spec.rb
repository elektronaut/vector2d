# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Clamping do
  subject(:vector) { Vector2d.new(2, 3) }

  describe "#clamp" do
    subject(:vector) { Vector2d.new(2, 8) }

    it "clamps each axis" do
      expect(vector.clamp(Vector2d.new(3, 3), Vector2d.new(6, 6)))
        .to eq(Vector2d.new(3, 6))
    end

    it "coerces the bounds" do
      expect(vector.clamp(3, 6)).to eq(Vector2d.new(3, 6))
    end

    it "leaves a vector within the bounds alone" do
      expect(vector.clamp(0, 10)).to eq(vector)
    end

    it "raises ArgumentError without an upper bound" do
      expect { vector.clamp(3) }.to raise_error(ArgumentError)
    end

    context "with a range" do
      it "clamps each axis" do
        expect(vector.clamp(3..6)).to eq(Vector2d.new(3, 6))
      end

      it "coerces the bounds" do
        expect(vector.clamp("3x3".."6x6")).to eq(Vector2d.new(3, 6))
      end

      it "leaves a vector within the bounds alone" do
        expect(vector.clamp(0..10)).to eq(vector)
      end

      it "matches the two argument form" do
        expect(vector.clamp(3..6)).to eq(vector.clamp(3, 6))
      end

      it "clamps only the upper bound of a beginless range" do
        expect(vector.clamp(..6)).to eq(Vector2d.new(2, 6))
      end

      it "clamps only the lower bound of an endless range" do
        expect(vector.clamp(3..)).to eq(Vector2d.new(3, 8))
      end

      it "leaves a vector bounded at neither end alone" do
        expect(vector.clamp(nil..nil)).to eq(vector)
      end

      it "matches #min for a beginless range" do
        expect(vector.clamp(..6)).to eq(vector.min(6))
      end

      it "matches #max for an endless range" do
        expect(vector.clamp(3..)).to eq(vector.max(3))
      end

      it "raises ArgumentError for an exclusive range" do
        expect { vector.clamp(3...6) }.to raise_error(ArgumentError)
      end

      it "raises ArgumentError when given a second argument" do
        expect { vector.clamp(3..6, 6) }.to raise_error(ArgumentError)
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
end
