# frozen_string_literal: true

require "spec_helper"
require "bigdecimal"
require "matrix"

describe Vector2d do
  subject(:vector) { described_class.new(2, 3) }

  coordinate_types = {
    "integer coordinates" => [2, 3],
    "float coordinates" => [2.0, 3.0],
    "rational coordinates" => [Rational(1, 2), Rational(3, 4)],
    "big decimal coordinates" => [BigDecimal("2.5"), BigDecimal("3.5")]
  }

  # Runs the block in a ractor with the argument as its only parameter,
  # and returns the value it produces.
  def in_ractor(argument, &)
    experimental = Warning[:experimental]
    Warning[:experimental] = false
    ractor = Ractor.new(argument, &)
    ractor.respond_to?(:value) ? ractor.value : ractor.take
  ensure
    Warning[:experimental] = experimental
  end

  describe "#frozen?" do
    subject { vector.frozen? }

    it { is_expected.to be(true) }

    coordinate_types.each do |description, (x, y)|
      context "with #{description}" do
        let(:vector) { described_class.new(x, y) }

        it { is_expected.to be(true) }
      end
    end

    context "with a vector built by an operation" do
      let(:vector) { described_class.new(2, 3) * 2 }

      it { is_expected.to be(true) }
    end

    context "with a vector built by .parse" do
      let(:vector) { described_class.parse("2x3") }

      it { is_expected.to be(true) }
    end

    context "with a vector built by .from_angle" do
      let(:vector) { described_class.from_angle(Math::PI / 4) }

      it { is_expected.to be(true) }
    end

    context "with a vector built by the helper method" do
      let(:vector) { Vector2d(2, 3) }

      it { is_expected.to be(true) }
    end

    context "with a clone" do
      let(:vector) { described_class.new(2, 3).clone }

      it { is_expected.to be(true) }
    end

    context "with a clone that asks not to be frozen" do
      let(:vector) { described_class.new(2, 3).clone(freeze: false) }

      it { is_expected.to be(true) }
    end

    context "with a dup" do
      let(:vector) { described_class.new(2, 3).dup }

      it { is_expected.to be(true) }
    end

    context "with a subclass" do
      let(:vector) { Class.new(described_class).new(2, 3) }

      it { is_expected.to be(true) }
    end
  end

  describe "assigning a coordinate" do
    it "raises FrozenError" do
      expect { vector.instance_variable_set(:@x, 5) }
        .to raise_error(FrozenError)
    end

    it "raises FrozenError on a dup" do
      expect { vector.dup.instance_variable_set(:@x, 5) }
        .to raise_error(FrozenError)
    end
  end

  describe "#dup" do
    subject(:duped) { vector.dup }

    it { is_expected.to eq(vector) }
    it { is_expected.to eql(vector) }

    it "is shareable" do
      expect(Ractor.shareable?(duped)).to be(true)
    end

    context "with a subclass carrying extra state" do
      subject(:duped) { labeled.new(2, 3, "point").dup }

      let(:labeled) do
        stub_const("DupLabeled", Class.new(described_class) do
          attr_reader :label

          def initialize(x, y, label = "unlabeled")
            @label = label
            super(x, y)
          end
        end)
      end

      it { is_expected.to be_frozen }
      its(:label) { is_expected.to eq("point") }
    end
  end

  describe "Ractor.shareable?" do
    subject { Ractor.shareable?(vector) }

    it { is_expected.to be(true) }

    coordinate_types.each do |description, (x, y)|
      context "with #{description}" do
        let(:vector) { described_class.new(x, y) }

        it { is_expected.to be(true) }
      end
    end

    context "with a vector built by an operation" do
      let(:vector) { described_class.new(2, 3) * 2 }

      it { is_expected.to be(true) }
    end

    context "with a coordinate that is not shareable" do
      let(:coordinate) { Class.new(Numeric).new }
      let(:vector) { described_class.new(2, coordinate) }

      it { is_expected.to be(false) }

      it "is still frozen" do
        expect(vector).to be_frozen
      end
    end
  end

  describe "sharing a vector with a ractor" do
    it "arrives frozen and unchanged" do
      result = in_ractor(vector) { |v| [v.frozen?, v.to_a] }

      expect(result).to eq([true, [2, 3]])
    end

    it "calculates with a vector argument" do
      result = in_ractor(vector) { |v| (v * Vector2d(2, 3)).to_a }

      expect(result).to eq([4, 9])
    end

    it "calculates with a coerced argument" do
      result = in_ractor(vector) { |v| ((v + 1) / "2x2").to_a }

      expect(result).to eq([1, 2])
    end

    it "transforms into a new vector" do
      result = in_ractor(vector) { |v| v.normalize.length }

      expect(result).to be_within(0.0001).of(1.0)
    end

    it "returns a vector that is still frozen" do
      result = in_ractor(vector, &:reverse)

      expect(result).to be_frozen
    end

    it "returns a vector equal to the expected one" do
      result = in_ractor(vector, &:reverse)

      expect(result).to eq(described_class.new(-2, -3))
    end

    it "transforms through a matrix" do
      result = in_ractor(vector) { |v| v.transform(Matrix[[0, -1], [1, 0]]).to_a }

      expect(result).to eq([-3, 2])
    end

    it "converts to a stdlib vector" do
      result = in_ractor(vector, &:to_vector)

      expect(result).to eq(Vector[2, 3])
    end
  end

  describe "a subclass adding instance variables" do
    let(:before_super) do
      stub_const("BeforeSuper", Class.new(described_class) do
        attr_reader :label

        def initialize(x, y, label = "unlabeled")
          @label = label
          super(x, y)
        end
      end)
    end

    let(:after_super) do
      stub_const("AfterSuper", Class.new(described_class) do
        def initialize(x, y, label = "unlabeled")
          super(x, y)
          @label = label
        end
      end)
    end

    context "when assigning before super" do
      subject(:vector) { before_super.new(2, 3, "point") }

      it { is_expected.to be_frozen }
      its(:label) { is_expected.to eq("point") }

      it "is shareable when the extra state is shareable" do
        expect(Ractor.shareable?(vector)).to be(true)
      end
    end

    context "when assigning after super" do
      it "raises FrozenError" do
        expect { after_super.new(2, 3) }.to raise_error(FrozenError)
      end
    end
  end

  describe ".parse with a vector argument" do
    subject(:parsed) { described_class.parse(vector) }

    it { is_expected.to be(vector) }
    it { is_expected.to be_frozen }
  end
end
