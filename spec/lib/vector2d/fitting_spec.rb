# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Fitting do
  let(:original) { Vector2d.new(300, 300) }

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

    context "when upscaling is enabled" do
      subject(:vector) { original.fit(comp, upscale: true) }

      let(:comp) { Vector2d.new(600, 600) }

      its(:x) { is_expected.to eq(600) }
      its(:y) { is_expected.to eq(600) }
    end

    context "when upscaling is disabled and the vector is larger" do
      subject(:vector) { original.fit(comp, upscale: false) }

      let(:comp) { Vector2d.new(200, 150) }

      its(:x) { is_expected.to eq(150) }
      its(:y) { is_expected.to eq(150) }
    end

    context "when upscaling is disabled and the vector already fits" do
      subject(:vector) { original.fit(comp, upscale: false) }

      let(:comp) { Vector2d.new(600, 600) }

      it { is_expected.to equal(original) }
    end

    context "when upscaling is disabled and the vector fits exactly" do
      subject(:vector) { original.fit(comp, upscale: false) }

      let(:comp) { Vector2d.new(300, 300) }

      it { is_expected.to equal(original) }
    end

    context "when upscaling is disabled and only one axis fits" do
      subject(:vector) { original.fit(comp, upscale: false) }

      let(:comp) { Vector2d.new(600, 150) }

      its(:x) { is_expected.to eq(150) }
      its(:y) { is_expected.to eq(150) }
    end

    context "when upscaling is disabled and the vector is negative" do
      subject(:vector) { original.fit(comp, upscale: false) }

      let(:original) { Vector2d.new(-20, -10) }
      let(:comp) { Vector2d.new(5, 5) }

      its(:x) { is_expected.to eq(-5) }
      its(:y) { is_expected.to eq(-2.5) }
    end

    context "when upscaling is disabled and the vector is unconstrained" do
      subject(:vector) { original.fit(comp, upscale: false) }

      let(:original) { Vector2d.new(20, 10) }
      let(:comp) { Vector2d.new(0, 0) }

      it { is_expected.to equal(original) }
    end
  end

  describe "#fits?" do
    subject { original.fits?(comp) }

    let(:original) { Vector2d.new(20, 10) }

    context "when the vector is smaller than the constraint" do
      let(:comp) { Vector2d.new(40, 40) }

      it { is_expected.to be(true) }
    end

    context "when the vector overflows the x axis" do
      let(:comp) { Vector2d.new(10, 40) }

      it { is_expected.to be(false) }
    end

    context "when the vector overflows the y axis" do
      let(:comp) { Vector2d.new(40, 5) }

      it { is_expected.to be(false) }
    end

    context "when the vector matches the constraint" do
      let(:comp) { Vector2d.new(20, 10) }

      it { is_expected.to be(true) }
    end

    context "when the coordinates are negative" do
      let(:original) { Vector2d.new(-20, -10) }
      let(:comp) { Vector2d.new(40, 40) }

      it { is_expected.to be(true) }
    end

    context "when an axis of the constraint is zero" do
      let(:comp) { Vector2d.new(0, 40) }

      it { is_expected.to be(true) }
    end

    context "when the unconstrained axis is the overflowing one" do
      let(:comp) { Vector2d.new(40, 0) }
      let(:original) { Vector2d.new(20, 80) }

      it { is_expected.to be(true) }
    end

    context "with the zero vector" do
      let(:original) { Vector2d.new(0, 0) }
      let(:comp) { Vector2d.new(40, 40) }

      it { is_expected.to be(true) }
    end

    it "coerces the constraint" do
      expect(original.fits?("40x40")).to be(true)
    end

    it "agrees with #fit" do
      [Vector2d.new(40, 40), Vector2d.new(10, 40),
       Vector2d.new(20, 10)].each do |c|
        expect(original.fits?(c))
          .to be(original.fit(c, upscale: false) == original)
      end
    end
  end

  describe "#cover" do
    subject(:vector) { original.cover(comp) }

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

    context "when upscaling is enabled" do
      subject(:vector) { original.cover(comp, upscale: true) }

      let(:comp) { Vector2d.new(600, 450) }

      its(:x) { is_expected.to eq(600) }
      its(:y) { is_expected.to eq(600) }
    end

    context "when upscaling is disabled and the vector is larger" do
      subject(:vector) { original.cover(comp, upscale: false) }

      let(:comp) { Vector2d.new(200, 150) }

      its(:x) { is_expected.to eq(200) }
      its(:y) { is_expected.to eq(200) }
    end

    context "when upscaling is disabled and the vector already covers" do
      subject(:vector) { original.cover(comp, upscale: false) }

      let(:comp) { Vector2d.new(600, 450) }

      it { is_expected.to equal(original) }
    end

    context "when upscaling is disabled and the vector covers exactly" do
      subject(:vector) { original.cover(comp, upscale: false) }

      let(:comp) { Vector2d.new(300, 200) }

      it { is_expected.to equal(original) }
    end

    context "when upscaling is disabled and a single axis constrains" do
      subject(:vector) { original.cover(comp, upscale: false) }

      let(:original) { Vector2d.new(0, 300) }
      let(:comp) { Vector2d.new(10, 600) }

      it { is_expected.to equal(original) }
    end

    context "when upscaling is disabled and a single axis scales it down" do
      subject(:vector) { original.cover(comp, upscale: false) }

      let(:original) { Vector2d.new(0, 300) }
      let(:comp) { Vector2d.new(10, 150) }

      its(:x) { is_expected.to eq(0) }
      its(:y) { is_expected.to eq(150) }
    end
  end

  describe "#covers?" do
    subject { original.covers?(comp) }

    let(:original) { Vector2d.new(20, 10) }

    context "when the vector is larger than the constraint" do
      let(:comp) { Vector2d.new(5, 5) }

      it { is_expected.to be(true) }
    end

    context "when the vector falls short on the y axis" do
      let(:original) { Vector2d.new(20, 1) }
      let(:comp) { Vector2d.new(5, 5) }

      it { is_expected.to be(false) }
    end

    context "when the vector falls short on the x axis" do
      let(:original) { Vector2d.new(1, 20) }
      let(:comp) { Vector2d.new(5, 5) }

      it { is_expected.to be(false) }
    end

    context "when the vector matches the constraint" do
      let(:comp) { Vector2d.new(20, 10) }

      it { is_expected.to be(true) }
    end

    context "when the coordinates are negative" do
      let(:original) { Vector2d.new(-20, -10) }
      let(:comp) { Vector2d.new(5, 5) }

      it { is_expected.to be(true) }
    end

    context "when an axis of the vector is zero" do
      let(:original) { Vector2d.new(0, 10) }
      let(:comp) { Vector2d.new(5, 5) }

      it { is_expected.to be(true) }
    end

    context "with the zero vector" do
      let(:original) { Vector2d.new(0, 0) }
      let(:comp) { Vector2d.new(5, 5) }

      it { is_expected.to be(true) }
    end

    it "coerces the constraint" do
      expect(original.covers?("5x5")).to be(true)
    end

    it "is true exactly when #cover doesn't scale the vector up" do
      [Vector2d.new(5, 5), Vector2d.new(40, 40),
       Vector2d.new(20, 10)].each do |c|
        expect(original.covers?(c))
          .to be(original.cover(c, upscale: false) == original.cover(c))
      end
    end
  end

  describe "#fit_either" do
    it "is an alias of #cover" do
      expect(original.fit_either(Vector2d.new(200, 150)))
        .to eq(Vector2d.new(200, 200))
    end
  end

  describe "#contain" do
    subject(:vector) { original.contain(comp) }

    it_behaves_like "a deprecated method", "contain",
                    "other.fit(self, upscale: false)" do
      let(:comp) { Vector2d.new(400, 300) }
    end

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

    context "when one axis is unconstrained and the other fits" do
      let(:original) { Vector2d.new(0, 10) }
      let(:comp) { Vector2d.new(5, 5) }

      it "does not scale the argument up" do
        expect(vector).to eq(Vector2d.new(5, 5))
      end
    end

    context "when one axis is unconstrained and the other does not fit" do
      let(:original) { Vector2d.new(0, 10) }
      let(:comp) { Vector2d.new(5, 20) }

      it "scales the argument down" do
        expect(vector).to eq(Vector2d.new(2.5, 10))
      end
    end

    context "when both vectors are zero" do
      let(:original) { Vector2d.new(0, 0) }
      let(:comp) { Vector2d.new(0, 0) }

      it "returns the argument unchanged" do
        expect(vector).to eq(Vector2d.new(0, 0))
      end
    end

    context "when the argument is invalid" do
      let(:comp) { "garbage" }

      it "raises an error" do
        expect { vector }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#constrain_both" do
    subject(:vector) { original.constrain_both(comp) }

    it_behaves_like "a deprecated method", "constrain_both", "#fit" do
      let(:comp) { Vector2d.new(200, 150) }
    end

    context "when the vector is larger than the constraint" do
      let(:comp) { Vector2d.new(200, 150) }

      it "matches #fit" do
        expect(vector).to eq(original.fit(comp))
      end
    end

    context "when the vector is smaller than the constraint" do
      let(:comp) { Vector2d.new(600, 600) }

      it "scales up, as #fit does" do
        expect(vector).to eq(Vector2d.new(600, 600))
      end
    end
  end

  describe "#constrain_one" do
    subject(:vector) { original.constrain_one(comp) }

    it_behaves_like "a deprecated method", "constrain_one", "#cover" do
      let(:comp) { Vector2d.new(200, 150) }
    end

    context "when width is largest" do
      let(:comp) { Vector2d.new(200, 150) }

      it "matches #cover" do
        expect(vector).to eq(original.cover(comp))
      end
    end

    context "when height is largest" do
      let(:comp) { Vector2d.new(150, 200) }

      it "matches #cover" do
        expect(vector).to eq(original.cover(comp))
      end
    end
  end
end
