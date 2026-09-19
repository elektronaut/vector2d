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

    context "when the vector is negative and wider" do
      let(:comp) { Vector2d.new(-400, 300) }

      its(:x) { is_expected.to eq(-300) }
      its(:y) { is_expected.to eq(225) }
    end

    context "when the vector is negative and higher" do
      let(:comp) { Vector2d.new(300, -400) }

      its(:x) { is_expected.to eq(225) }
      its(:y) { is_expected.to eq(-300) }
    end

    context "when both coordinates are negative" do
      let(:comp) { Vector2d.new(-400, -300) }

      its(:x) { is_expected.to eq(-300) }
      its(:y) { is_expected.to eq(-225) }
    end

    context "when the negative vector already fits" do
      let(:comp) { Vector2d.new(-150, -100) }

      its(:x) { is_expected.to eq(-150) }
      its(:y) { is_expected.to eq(-100) }
    end

    context "when the vector is unconstrained" do
      let(:original) { Vector2d.new(0, 0) }
      let(:comp) { Vector2d.new(40, 20) }

      it "returns the argument unchanged" do
        expect(vector).to eq(Vector2d.new(40, 20))
      end
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

    context "when the x coordinate is negative" do
      let(:original) { Vector2d.new(-20, 10) }
      let(:comp) { Vector2d.new(5, 5) }

      its(:x) { is_expected.to eq(-5) }
      its(:y) { is_expected.to eq(2.5) }
    end

    context "when the y coordinate is negative" do
      let(:original) { Vector2d.new(20, -10) }
      let(:comp) { Vector2d.new(5, 5) }

      its(:x) { is_expected.to eq(5) }
      its(:y) { is_expected.to eq(-2.5) }
    end

    context "when both coordinates are negative" do
      let(:original) { Vector2d.new(-20, -10) }
      let(:comp) { Vector2d.new(5, 5) }

      its(:x) { is_expected.to eq(-5) }
      its(:y) { is_expected.to eq(-2.5) }
    end

    context "when both coordinates are negative and the y axis binds" do
      let(:original) { Vector2d.new(-10, -20) }
      let(:comp) { Vector2d.new(5, 5) }

      its(:x) { is_expected.to eq(-2.5) }
      its(:y) { is_expected.to eq(-5) }
    end

    context "when the constraint is negative" do
      let(:original) { Vector2d.new(20, 10) }
      let(:comp) { Vector2d.new(-5, -5) }

      its(:x) { is_expected.to eq(5) }
      its(:y) { is_expected.to eq(2.5) }
    end

    context "with the zero vector" do
      let(:original) { Vector2d.new(0, 0) }
      let(:comp) { Vector2d.new(5, 5) }

      it "returns the zero vector" do
        expect(vector).to eq(Vector2d.new(0, 0))
      end
    end

    context "when the argument is invalid" do
      let(:comp) { "garbage" }

      it "raises an error" do
        expect { vector }.to raise_error(ArgumentError)
      end
    end

    context "when the vector is zero and the argument is invalid" do
      let(:original) { Vector2d.new(0, 0) }
      let(:comp) { "garbage" }

      it "raises an error" do
        expect { vector }.to raise_error(ArgumentError)
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

    context "when both constraint axes are zero" do
      let(:original) { Vector2d.new(20, 10) }
      let(:comp) { Vector2d.new(0, 0) }

      it "returns the vector unchanged" do
        expect(vector).to eq(Vector2d.new(20, 10))
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

    context "when a coordinate is negative and width is largest" do
      let(:original) { Vector2d.new(-300, 300) }
      let(:comp) { Vector2d.new(200, 150) }

      its(:x) { is_expected.to eq(-200) }
      its(:y) { is_expected.to eq(200) }
    end

    context "when a coordinate is negative and height is largest" do
      let(:original) { Vector2d.new(300, -300) }
      let(:comp) { Vector2d.new(150, 200) }

      its(:x) { is_expected.to eq(200) }
      its(:y) { is_expected.to eq(-200) }
    end

    context "when both coordinates are negative" do
      let(:original) { Vector2d.new(-20, -10) }
      let(:comp) { Vector2d.new(5, 5) }

      its(:x) { is_expected.to eq(-10) }
      its(:y) { is_expected.to eq(-5) }
    end

    context "when the constraint is negative" do
      let(:original) { Vector2d.new(20, 10) }
      let(:comp) { Vector2d.new(-5, -5) }

      its(:x) { is_expected.to eq(10) }
      its(:y) { is_expected.to eq(5) }
    end

    context "with the zero vector" do
      let(:original) { Vector2d.new(0, 0) }
      let(:comp) { Vector2d.new(5, 5) }

      it "returns the zero vector" do
        expect(vector).to eq(Vector2d.new(0, 0))
      end
    end

    context "when the argument is invalid" do
      let(:comp) { "garbage" }

      it "raises an error" do
        expect { vector }.to raise_error(ArgumentError)
      end
    end

    context "when the vector is zero and the argument is invalid" do
      let(:original) { Vector2d.new(0, 0) }
      let(:comp) { "garbage" }

      it "raises an error" do
        expect { vector }.to raise_error(ArgumentError)
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

    context "when both constraint axes are zero" do
      let(:original) { Vector2d.new(20, 10) }
      let(:comp) { Vector2d.new(0, 0) }

      it "returns the vector unchanged" do
        expect(vector).to eq(Vector2d.new(20, 10))
      end

      it "matches #fit" do
        expect(vector).to eq(original.fit(comp))
      end
    end
  end
end
