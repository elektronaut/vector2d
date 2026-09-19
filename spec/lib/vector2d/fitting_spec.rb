# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Fitting do
  let(:original) { Vector2d.new(300, 300) }

  describe "#contain" do
    subject(:vector) { original.contain(comp) }

    context "when vector is smaller" do
      let(:comp) { Vector2d.new(150, 100) }

      its(:x) { is_expected.to eq(150) }
      its(:y) { is_expected.to eq(100) }
    end

    context "when vector is wider" do
      let(:comp) { Vector2d.new(400, 300) }

      its(:x) { is_expected.to eq(300) }
      its(:y) { is_expected.to eq(225) }
    end

    context "when vector is higher" do
      let(:comp) { Vector2d.new(300, 400) }

      its(:x) { is_expected.to eq(225) }
      its(:y) { is_expected.to eq(300) }
    end

    context "when the argument is an array" do
      let(:comp) { [400, 300] }

      its(:x) { is_expected.to eq(300) }
      its(:y) { is_expected.to eq(225) }
    end

    context "when the argument is a string" do
      let(:comp) { "400x300" }

      its(:x) { is_expected.to eq(300) }
      its(:y) { is_expected.to eq(225) }
    end

    context "when the argument is a hash" do
      let(:comp) { { x: 400, y: 300 } }

      its(:x) { is_expected.to eq(300) }
      its(:y) { is_expected.to eq(225) }
    end

    context "when the coerced argument already fits" do
      let(:comp) { [150, 100] }

      it { is_expected.to be_a(Vector2d) }
      its(:x) { is_expected.to eq(150) }
      its(:y) { is_expected.to eq(100) }
    end
  end

  describe "#fit" do
    subject(:vector) { original.fit(comp) }

    context "when scaling by height" do
      let(:comp) { Vector2d.new(200, 150) }

      its(:x) { is_expected.to eq(150) }
      its(:y) { is_expected.to eq(150) }
    end

    context "when scaling by width" do
      let(:comp) { Vector2d.new(150, 200) }

      its(:x) { is_expected.to eq(150) }
      its(:y) { is_expected.to eq(150) }
    end

    context "with the zero vector" do
      let(:original) { Vector2d.new(0, 0) }
      let(:comp) { Vector2d.new(5, 5) }

      it "returns the zero vector" do
        expect(vector).to eq(Vector2d.new(0, 0))
      end
    end

    context "when the x axis is zero" do
      let(:original) { Vector2d.new(0, 5) }
      let(:comp) { Vector2d.new(10, 2) }

      it "disregards the zero axis" do
        expect(vector).to eq(Vector2d.new(0.0, 2.0))
      end
    end

    context "when the y axis is zero" do
      let(:original) { Vector2d.new(5, 0) }
      let(:comp) { Vector2d.new(2, 10) }

      it "disregards the zero axis" do
        expect(vector).to eq(Vector2d.new(2.0, 0.0))
      end
    end
  end

  describe "#fit_either" do
    subject(:vector) { original.fit_either(comp) }

    let(:original) { Vector2d.new(300, 300) }

    context "when width is largest" do
      let(:comp) { Vector2d.new(200, 150) }

      its(:x) { is_expected.to eq(200) }
      its(:y) { is_expected.to eq(200) }
    end

    context "when height is largest" do
      let(:comp) { Vector2d.new(150, 200) }

      its(:x) { is_expected.to eq(200) }
      its(:y) { is_expected.to eq(200) }
    end

    context "when a coordinate is negative" do
      let(:original) { Vector2d.new(-300, 300) }
      let(:comp) { Vector2d.new(150, 150) }

      its(:x) { is_expected.to eq(-150) }
      its(:y) { is_expected.to eq(150) }
    end

    context "with the zero vector" do
      let(:original) { Vector2d.new(0, 0) }
      let(:comp) { Vector2d.new(5, 5) }

      it "returns the zero vector" do
        expect(vector).to eq(Vector2d.new(0, 0))
      end
    end

    context "when the x axis is zero" do
      let(:original) { Vector2d.new(0, 5) }
      let(:comp) { Vector2d.new(10, 2) }

      it "disregards the zero axis" do
        expect(vector).to eq(Vector2d.new(0.0, 2.0))
      end

      it "matches #fit" do
        expect(vector).to eq(original.fit(comp))
      end
    end

    context "when the y axis is zero" do
      let(:original) { Vector2d.new(5, 0) }
      let(:comp) { Vector2d.new(2, 10) }

      it "disregards the zero axis" do
        expect(vector).to eq(Vector2d.new(2.0, 0.0))
      end

      it "matches #fit" do
        expect(vector).to eq(original.fit(comp))
      end
    end
  end
end
