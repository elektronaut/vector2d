# frozen_string_literal: true

require "spec_helper"

describe Vector2d do
  subject(:vector) { described_class.new(2, 3) }

  describe "helper method" do
    it "creates a vector" do
      expect(Vector2d(2, 3)).to eq(described_class.new(2, 3))
    end
  end

  describe ".new" do
    it "creates a vector from two coordinates" do
      expect(described_class.new(2, 3).to_a).to eq([2, 3])
    end

    context "with a complex x" do
      it "raises an error" do
        expect { described_class.new(Complex(1, 2), 3) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end

    context "with a complex y" do
      it "raises an error" do
        expect { described_class.new(2, Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end

    context "with a non-numeric coordinate" do
      it "raises an error" do
        expect { described_class.new(2, nil) }.to(
          raise_error(ArgumentError, "not a valid coordinate: nil")
        )
      end
    end
  end

  describe "#==" do
    subject { vector == comp }

    context "with both arguments equal" do
      let(:comp) { described_class.new(2, 3) }

      it { is_expected.to be(true) }
    end

    context "with x differing" do
      let(:comp) { described_class.new(3, 3) }

      it { is_expected.to be(false) }
    end

    context "with y differing" do
      let(:comp) { described_class.new(2, 4) }

      it { is_expected.to be(false) }
    end

    context "with a number argument" do
      let(:comp) { 5 }

      it { is_expected.to be(false) }
    end

    context "with an array argument" do
      let(:comp) { [2, 3] }

      it { is_expected.to be(false) }
    end

    context "with a string argument" do
      let(:comp) { "2x3" }

      it { is_expected.to be(false) }
    end

    context "with a nil argument" do
      let(:comp) { nil }

      it { is_expected.to be(false) }
    end
  end

  describe "#eql?" do
    subject { vector.eql?(comp) }

    context "with both arguments equal" do
      let(:comp) { described_class.new(2, 3) }

      it { is_expected.to be(true) }
    end

    context "with x differing" do
      let(:comp) { described_class.new(3, 3) }

      it { is_expected.to be(false) }
    end

    context "with y differing" do
      let(:comp) { described_class.new(2, 4) }

      it { is_expected.to be(false) }
    end

    context "with coordinates of a different type" do
      let(:comp) { described_class.new(2.0, 3.0) }

      it { is_expected.to be(false) }
    end

    context "with a subclass" do
      let(:comp) { Class.new(described_class).new(2, 3) }

      it { is_expected.to be(false) }
    end

    context "with a non-vector" do
      let(:comp) { [2, 3] }

      it { is_expected.to be(false) }
    end
  end

  describe "#hash" do
    subject { vector.hash }

    context "with an equal vector" do
      it { is_expected.to eq(described_class.new(2, 3).hash) }
    end

    context "with a differing vector" do
      it { is_expected.not_to eq(described_class.new(3, 2).hash) }
    end

    context "with coordinates of a different type" do
      it { is_expected.not_to eq(described_class.new(2.0, 3.0).hash) }
    end

    it "makes vectors usable as hash keys" do
      expect({ vector => :value }[described_class.new(2, 3)]).to be(:value)
    end

    it "deduplicates equal vectors in arrays" do
      expect([vector] | [described_class.new(2, 3)]).to eq([vector])
    end
  end
end
