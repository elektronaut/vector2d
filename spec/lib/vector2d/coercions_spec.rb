# frozen_string_literal: true

require "spec_helper"

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
    subject { vector.to_f_vector }

    its(:x) { is_expected.to be_a(Float) }
    its(:y) { is_expected.to be_a(Float) }
  end

  describe "#to_hash" do
    it "returns a hash" do
      expect(vector.to_hash).to eq(x: 2, y: 3)
    end
  end

  describe "#to_i_vector" do
    subject { vector.to_i_vector }

    let(:vector) { Vector2d.new(2.0, 3.0) }

    its(:x) { is_expected.to be_a(Integer) }
    its(:y) { is_expected.to be_a(Integer) }
  end

  describe "#to_s" do
    context "when fixnum" do
      subject(:vector) { Vector2d.new(2, 3) }

      it "renders a string" do
        expect(vector.to_s).to eq("2x3")
      end
    end

    context "when float" do
      subject(:vector) { Vector2d.new(2.0, 3.0) }

      it "renders a string" do
        expect(vector.to_s).to eq("2.0x3.0")
      end
    end
  end
end
