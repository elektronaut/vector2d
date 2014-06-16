# encoding: utf-8

require 'spec_helper'

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
    it "normalizes the vector" do
      expect(vector.normalize.x).to be_within(0.0001).of(0.5547)
      expect(vector.normalize.y).to be_within(0.0001).of(0.8320)
    end
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
      expect(resized.x).to be_within(0.0001).of(1.1094)
      expect(resized.y).to be_within(0.0001).of(1.6641)
    end
  end

  describe "#reverse" do
    it "reverses the vector" do
      expect(vector.reverse).to eq(Vector2d.new(-2, -3))
    end
  end

  describe "#round" do
    subject(:vector) { Vector2d.new(2.3, 3.6) }
    it "rounds the vector" do
      expect(vector.round).to eq(Vector2d.new(2, 4))
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