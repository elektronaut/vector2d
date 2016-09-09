# encoding: utf-8

require "spec_helper"

describe Vector2d do
  subject(:vector) { Vector2d.new(2, 3) }

  shared_examples "a parsed vector" do |x, y|
    it "receives the x and y properties" do
      expect(subject.x).to eq(x)
      expect(subject.y).to eq(y)
    end
  end

  describe "helper method" do
    it "creates a vector" do
      expect(Vector2d(2, 3)).to eq(Vector2d.new(2, 3))
    end
  end

  describe ".parse" do
    context "with fixnum argument" do
      subject(:vector) { Vector2d.parse(2) }
      it_behaves_like "a parsed vector", [2, 2]
    end

    context "with two arguments, fixnum" do
      subject(:vector) { Vector2d.parse(1, 2) }
      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with two arguments, float" do
      subject(:vector) { Vector2d.parse(1.0, 2.0) }
      it_behaves_like "a parsed vector", [1.0, 2.0]
    end

    context "with string argument, first omitted" do
      subject(:vector) { Vector2d.parse("x200") }
      it_behaves_like "a parsed vector", [0, 200]
    end

    context "with string argument, second omitted" do
      subject(:vector) { Vector2d.parse("200x") }
      it_behaves_like "a parsed vector", [200, 0]
    end

    context "with string argument, fixnum" do
      subject(:vector) { Vector2d.parse("1x2") }
      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with string argument, float" do
      subject(:vector) { Vector2d.parse("1.0x2.0") }
      it_behaves_like "a parsed vector", [1.0, 2.0]
    end

    context "with array argument" do
      subject(:vector) { Vector2d.parse([1, 2]) }
      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with hash argument, symbol keys" do
      subject(:vector) { Vector2d.parse(x: 1, y: 2) }
      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with hash argument, string keys" do
      subject(:vector) { Vector2d.parse("x" => 1, "y" => 2) }
      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with vector argument" do
      subject(:vector) { Vector2d.parse(Vector2d.new(1, 2)) }
      it_behaves_like "a parsed vector", [1, 2]
    end
  end

  describe "#==" do
    subject { vector == comp }

    context "with both arguments equal" do
      let(:comp) { Vector2d.new(2, 3) }
      it { is_expected.to eq(true) }
    end

    context "with x differing" do
      let(:comp) { Vector2d.new(3, 3) }
      it { is_expected.to eq(false) }
    end

    context "with y differing" do
      let(:comp) { Vector2d.new(2, 4) }
      it { is_expected.to eq(false) }
    end
  end
end
