# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Transformations do
  subject(:vector) { Vector2d.new(2, 3) }

  describe "#ceil" do
    subject(:vector) { Vector2d.new(2.3, 3.3) }

    it "rounds the vector up" do
      expect(vector.ceil).to eq(Vector2d.new(3, 4))
    end
  end

  describe "#floor" do
    subject(:vector) { Vector2d.new(2.7, 3.6) }

    it "rounds the vector down" do
      expect(vector.floor).to eq(Vector2d.new(2, 3))
    end
  end

  describe "#normalize" do
    subject { vector.normalize }

    its(:x) { is_expected.to be_within(0.0001).of(0.5547) }
    its(:y) { is_expected.to be_within(0.0001).of(0.8320) }
  end

  describe "#perpendicular" do
    it "returns a perpendicular vector" do
      expect(vector.perpendicular).to eq(Vector2d.new(-3, 2))
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
    context "when argument is longer than length" do
      let(:arg) { 5.0 }

      it "does not change the length" do
        expect(vector.truncate(arg).length).to be_within(0.0001).of(3.6055)
      end
    end

    context "when argument is shorter than length" do
      let(:arg) { 2.5 }

      it "changes the length" do
        expect(vector.truncate(arg).length).to be_within(0.0001).of(arg)
      end
    end
  end
end
