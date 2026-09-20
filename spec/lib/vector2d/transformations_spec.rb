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
  end

  describe "#truncate" do
    it "is an alias of #clamp_length" do
      expect(vector.truncate(2.5).length).to be_within(0.0001).of(2.5)
    end
  end
end
