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
  end

  describe "#length" do
    it "calculates the length" do
      expect(vector.length).to be_within(0.0001).of(3.6055)
    end
  end

  describe "#squared_length" do
    it "calculates the squared length" do
      expect(vector.squared_length).to eq(13)
    end
  end

  describe "#normalized?" do
    subject { vector.normalized? }

    context "when vector is normalized" do
      let(:vector) { Vector2d.new(2, 3).normalize }

      it { is_expected.to eq(true) }
    end

    context "when vector isn't normalized" do
      let(:vector) { Vector2d.new(2, 3) }

      it { is_expected.to eq(false) }
    end
  end
end
