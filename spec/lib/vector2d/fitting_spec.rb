# encoding: utf-8

require 'spec_helper'

describe Vector2d::Fitting do
  let(:original) { Vector2d.new(300, 300) }

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

  describe "#contrain_one" do
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