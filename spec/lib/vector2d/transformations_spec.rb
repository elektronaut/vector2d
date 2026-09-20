# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Transformations do
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

  describe "#perpendicular" do
    it "returns a perpendicular vector" do
      expect(vector.perpendicular).to eq(Vector2d.new(-3, 2))
    end

    it "turns the same way as #rotate" do
      expect(vector.perpendicular.round(3))
        .to eq(vector.rotate(Math::PI / 2).round(3))
    end
  end

  describe "#perpendicular_ccw" do
    it "is an alias of #perpendicular" do
      expect(vector.perpendicular_ccw).to eq(vector.perpendicular)
    end
  end

  describe "#perpendicular_cw" do
    it "returns a perpendicular vector" do
      expect(vector.perpendicular_cw).to eq(Vector2d.new(3, -2))
    end

    it "turns the opposite way from #perpendicular" do
      expect(vector.perpendicular_cw).to eq(vector.perpendicular.reverse)
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

  describe "#reverse" do
    it "reverses the vector" do
      expect(vector.reverse).to eq(Vector2d.new(-2, -3))
    end
  end

  describe "#rotate" do
    subject { vector.rotate(rotation).round(3) }

    let(:vector) { Vector2d.new(1, 0) }

    context "when roating by PI" do
      let(:rotation) { Math::PI }

      it { is_expected.to eq(Vector2d.new(-1, 0)) }
    end

    context "when roating by PI/2" do
      let(:rotation) { Math::PI / 2 }

      it { is_expected.to eq(Vector2d.new(0, 1)) }
    end

    context "when roating by -PI/2" do
      let(:rotation) { -Math::PI / 2 }

      it { is_expected.to eq(Vector2d.new(0, -1)) }
    end

    context "when roating by PI/4" do
      let(:rotation) { Math::PI / 4 }

      it { is_expected.to eq(Vector2d.new(0.707, 0.707)) }
    end

    context "with a complex angle" do
      it "raises an error" do
        expect { vector.rotate(Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end
  end

  describe "#rotate_around" do
    subject { vector.rotate_around(center, Math::PI / 2).round(3) }

    let(:vector) { Vector2d.new(2, 1) }
    let(:center) { Vector2d.new(1, 1) }

    it { is_expected.to eq(Vector2d.new(1, 2)) }

    context "when the center is the origin" do
      let(:center) { Vector2d.new(0, 0) }

      it { is_expected.to eq(vector.rotate(Math::PI / 2).round(3)) }
    end

    context "when the center is the vector itself" do
      let(:center) { vector }

      it { is_expected.to eq(vector) }
    end

    context "with a coercible center" do
      let(:center) { [1, 1] }

      it { is_expected.to eq(Vector2d.new(1, 2)) }
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

  describe "#truncate" do
    subject(:vector) { Vector2d.new(2, 3).truncate(2.5) }

    it_behaves_like "a deprecated method", "truncate", "#clamp_length"

    it "clamps the length, as #clamp_length does" do
      expect(vector.length).to be_within(0.0001).of(2.5)
    end
  end
end
