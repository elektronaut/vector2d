# encoding: utf-8

require 'spec_helper'

describe Vector2d::Fitting do
  let(:original) { Vector2d.new(300, 300) }

  describe "#contain" do
    subject(:vector) { original.contain(comp) }

    context "when vector is smaller" do
      let(:comp) { Vector2d.new(150, 100) }
      it "should not change it" do
        expect(vector.x).to eq(150)
        expect(vector.y).to eq(100)
      end
    end

    context "when vector is wider" do
      let(:comp) { Vector2d.new(400, 300) }
      it "should scale it down" do
        expect(vector.x).to eq(300)
        expect(vector.y).to eq(225)
      end
    end

    context "when vector is higher" do
      let(:comp) { Vector2d.new(300, 400) }
      it "should scale it down" do
        expect(vector.x).to eq(225)
        expect(vector.y).to eq(300)
      end
    end
  end

  describe "#fit" do
    subject(:vector) { original.fit(comp) }

    context "when scaling by height" do
      let(:comp) { Vector2d.new(200, 150) }
      it "should fit within the other vector" do
        expect(vector.x).to eq(150)
        expect(vector.y).to eq(150)
      end
    end

    context "when scaling by width" do
      let(:comp) { Vector2d.new(150, 200) }
      it "should fit within the other vector" do
        expect(vector.x).to eq(150)
        expect(vector.y).to eq(150)
      end
    end
  end

  describe "#fit_either" do
    let(:original) { Vector2d.new(300, 300) }
    subject(:vector) { original.fit_either(comp) }

    context "when width is largest" do
      let(:comp) { Vector2d.new(200, 150) }
      it "should be the same width" do
        expect(vector.x).to eq(200)
        expect(vector.y).to eq(200)
      end
    end

    context "when height is largest" do
      let(:comp) { Vector2d.new(150, 200) }
      it "should be the same height" do
        expect(vector.x).to eq(200)
        expect(vector.y).to eq(200)
      end
    end
  end
end