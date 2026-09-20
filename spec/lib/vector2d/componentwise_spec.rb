# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Componentwise do
  subject(:vector) { Vector2d.new(2, 3) }

  describe "#abs" do
    it "returns the absolute value of each axis" do
      expect(Vector2d.new(-2, 3).abs).to eq(Vector2d.new(2, 3))
    end

    it "leaves a positive vector alone" do
      expect(vector.abs).to eq(vector)
    end

    it "is component-wise, not the length" do
      expect(Vector2d.new(-2, -3).abs).to eq(Vector2d.new(2, 3))
    end
  end

  describe "#ceil" do
    subject(:vector) { Vector2d.new(2.3, 3.3) }

    it "rounds the vector up" do
      expect(vector.ceil).to eq(Vector2d.new(3, 4))
    end

    it "rounds up to the given precision" do
      expect(Vector2d.new(2.441, 3.666).ceil(2))
        .to eq(Vector2d.new(2.45, 3.67))
    end

    it "rounds up to a negative precision" do
      expect(Vector2d.new(24.4, 36.6).ceil(-1)).to eq(Vector2d.new(30, 40))
    end
  end

  describe "#floor" do
    subject(:vector) { Vector2d.new(2.7, 3.6) }

    it "rounds the vector down" do
      expect(vector.floor).to eq(Vector2d.new(2, 3))
    end

    it "rounds down to the given precision" do
      expect(Vector2d.new(2.444, 3.669).floor(2))
        .to eq(Vector2d.new(2.44, 3.66))
    end

    it "rounds down to a negative precision" do
      expect(Vector2d.new(24.4, 36.6).floor(-1)).to eq(Vector2d.new(20, 30))
    end
  end

  describe "#round" do
    let(:vector) { Vector2d.new(2.3333, 3.666) }

    context "without argument" do
      subject { vector.round }

      it { is_expected.to eq(Vector2d.new(2, 4)) }
    end

    context "with precision" do
      subject { vector.round(2) }

      it { is_expected.to eq(Vector2d.new(2.33, 3.67)) }
    end
  end

  describe "#truncate" do
    subject(:vector) { Vector2d.new(2, 3).truncate(2.5) }

    it_behaves_like "a deprecated method", "truncate", "#limit_length"

    it "limits the length, as #limit_length does" do
      expect(vector.length).to be_within(0.0001).of(2.5)
    end
  end

  describe "#sign" do
    it "returns the sign of each axis" do
      expect(Vector2d.new(-2, 3).sign).to eq(Vector2d.new(-1, 1))
    end

    it "is zero for an axis that is zero" do
      expect(Vector2d.new(0, -3).sign).to eq(Vector2d.new(0, -1))
    end

    it "returns integers for a float vector" do
      expect(Vector2d.new(-2.5, 0.0).sign.to_a).to eq([-1, 0])
    end

    it "treats negative zero as zero" do
      expect(Vector2d.new(-0.0, 1).sign).to eq(Vector2d.new(0, 1))
    end

    context "when a coordinate is NaN" do
      it "raises an error" do
        expect { Vector2d.new(Float::NAN, 3).sign }.to(
          raise_error(ArgumentError, "NaN has no sign")
        )
      end
    end
  end

  describe "#snap" do
    subject(:vector) { Vector2d.new(23, 47) }

    it "snaps each axis to the nearest multiple" do
      expect(vector.snap(10)).to eq(Vector2d.new(20, 50))
    end

    it "takes a step per axis" do
      expect(vector.snap(Vector2d.new(10, 5))).to eq(Vector2d.new(20, 45))
    end

    it "coerces the step" do
      expect(vector.snap("10x5")).to eq(Vector2d.new(20, 45))
    end

    it "leaves a vector on the grid alone" do
      expect(Vector2d.new(20, 50).snap(10)).to eq(Vector2d.new(20, 50))
    end

    it "snaps negative coordinates away from zero at the halfway point" do
      expect(Vector2d.new(-15, -25).snap(10)).to eq(Vector2d.new(-20, -30))
    end

    it "handles a negative step" do
      expect(vector.snap(-10)).to eq(Vector2d.new(20, 50))
    end

    context "with a fractional step" do
      subject(:vector) { Vector2d.new(2.3, 3.7) }

      it "snaps to the fractional grid" do
        expect(vector.snap(0.5)).to eq(Vector2d.new(2.5, 3.5))
      end

      it "keeps the type of the step" do
        expect(vector.snap(1)).to eql(Vector2d.new(2, 4))
      end
    end

    context "when the step is zero" do
      it "leaves both axes unchanged" do
        expect(vector.snap(0)).to eq(vector)
      end

      it "leaves only the unstepped axis unchanged" do
        expect(vector.snap(Vector2d.new(10, 0))).to eq(Vector2d.new(20, 47))
      end
    end
  end

  describe "#max" do
    subject(:vector) { Vector2d.new(2, 8) }

    it "returns the larger value of each axis" do
      expect(vector.max(Vector2d.new(5, 5))).to eq(Vector2d.new(5, 8))
    end

    it "coerces the argument" do
      expect(vector.max(5)).to eq(Vector2d.new(5, 8))
    end

    it "is symmetric" do
      other = Vector2d.new(5, 5)
      expect(other.max(vector)).to eq(vector.max(other))
    end
  end

  describe "#min" do
    subject(:vector) { Vector2d.new(2, 8) }

    it "returns the smaller value of each axis" do
      expect(vector.min(Vector2d.new(5, 5))).to eq(Vector2d.new(2, 5))
    end

    it "coerces the argument" do
      expect(vector.min(5)).to eq(Vector2d.new(2, 5))
    end

    it "is symmetric" do
      other = Vector2d.new(5, 5)
      expect(other.min(vector)).to eq(vector.min(other))
    end
  end

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

  describe "#with_x" do
    it "replaces x" do
      expect(vector.with_x(5)).to eq(Vector2d.new(5, 3))
    end

    it "keeps the type of the new coordinate" do
      expect(vector.with_x(5.0).x).to be_a(Float)
    end

    it "leaves the receiver alone" do
      expect { vector.with_x(5) }.not_to change(vector, :to_a)
    end

    it "raises an error on a string" do
      expect { vector.with_x("5") }.to(
        raise_error(ArgumentError, 'not a valid coordinate: "5"')
      )
    end

    it "raises an error on nil" do
      expect { vector.with_x(nil) }.to(
        raise_error(ArgumentError, "not a valid coordinate: nil")
      )
    end
  end

  describe "#with_y" do
    it "replaces y" do
      expect(vector.with_y(5)).to eq(Vector2d.new(2, 5))
    end

    it "keeps the type of the new coordinate" do
      expect(vector.with_y(5.0).y).to be_a(Float)
    end

    it "raises an error on a vector" do
      expect { vector.with_y(Vector2d.new(2, 3)) }.to(
        raise_error(ArgumentError, "not a valid coordinate: Vector2d(2,3)")
      )
    end
  end
end
