# encoding: utf-8

require 'spec_helper'

describe Vector2d::Coercions do
  subject(:vector) { Vector2d.new(2, 3) }

  describe "#inspect" do
    it "renders a string representation" do
      expect(vector.inspect).to eq("Vector2d(2,3)")
    end
  end

  describe "#to_a" do
    it "returns an array" do
      expect(vector.to_a).to eq([2, 3])
    end
  end

  describe "#to_f_vector" do
    it "returns a float vector" do
      expect(vector.to_f_vector.x).to be_a(Float)
      expect(vector.to_f_vector.y).to be_a(Float)
    end
  end

  describe "#to_hash" do
    it "returns a hash" do
      expect(vector.to_hash).to eq({x: 2, y: 3})
    end
  end

  describe "#to_i_vector" do
    subject(:vector) { Vector2d.new(2.0, 3.0) }
    it "returns a fixnum vector" do
      expect(vector.to_i_vector.x).to be_a(Fixnum)
      expect(vector.to_i_vector.y).to be_a(Fixnum)
    end
  end

  describe "#to_s" do
    context "when fixnum" do
      subject(:vector) { Vector2d.new(2, 3) }
      it "renders a string" do
        expect(vector.to_s).to eq('2x3')
      end
    end
    context "when float" do
      subject(:vector) { Vector2d.new(2.0, 3.0) }
      it "renders a string" do
        expect(vector.to_s).to eq('2.0x3.0')
      end
    end
  end
end