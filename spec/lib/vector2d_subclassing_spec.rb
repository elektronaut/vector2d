# frozen_string_literal: true

require "spec_helper"
require "matrix"

describe Vector2d do
  subject(:vector) { subclass.new(2.5, 3.5) }

  let(:subclass) { stub_const("SubVector", Class.new(described_class)) }

  it_behaves_like "a class preserving method", :*, 2
  it_behaves_like "a class preserving method", :/, 2
  it_behaves_like "a class preserving method", :+, 2
  it_behaves_like "a class preserving method", :-, 2
  it_behaves_like "a class preserving method", :-@
  it_behaves_like "a class preserving method", :+@
  it_behaves_like "a class preserving method", :project, 2
  it_behaves_like "a class preserving method", :reflect, 2
  it_behaves_like "a class preserving method", :reject, 2

  it_behaves_like "a class preserving method", :transform,
                  Matrix[[0, -1], [1, 0]]

  it_behaves_like "a class preserving method", :to_i_vector
  it_behaves_like "a class preserving method", :to_f_vector

  it_behaves_like "a class preserving method", :fit, 10
  it_behaves_like "a class preserving method", :cover, 10
  it_behaves_like "a class preserving method", :fit_either, 10

  it_behaves_like "a class preserving method", :abs
  it_behaves_like "a class preserving method", :ceil
  it_behaves_like "a class preserving method", :clamp, 0, 10
  it_behaves_like "a class preserving method", :clamp, 0..10
  it_behaves_like "a class preserving method", :clamp_length, 1.0
  it_behaves_like "a class preserving method", :floor
  it_behaves_like "a class preserving method", :lerp, 2, 0.5
  it_behaves_like "a class preserving method", :max, 2
  it_behaves_like "a class preserving method", :midpoint, 2
  it_behaves_like "a class preserving method", :min, 2
  it_behaves_like "a class preserving method", :normalize
  it_behaves_like "a class preserving method", :perpendicular
  it_behaves_like "a class preserving method", :perpendicular_ccw
  it_behaves_like "a class preserving method", :perpendicular_cw
  it_behaves_like "a class preserving method", :resize, 2.0
  it_behaves_like "a class preserving method", :reverse
  it_behaves_like "a class preserving method", :rotate, Math::PI
  it_behaves_like "a class preserving method", :rotate_degrees, 180
  it_behaves_like "a class preserving method", :rotate_around, 0, Math::PI
  it_behaves_like "a class preserving method", :round
  it_behaves_like "a class preserving method", :snap, 1

  describe ".from_angle" do
    it "returns an instance of the receiver's class" do
      expect(subclass.from_angle(Math::PI / 2))
        .to be_an_instance_of(subclass)
    end
  end

  describe ".from_degrees" do
    it "returns an instance of the receiver's class" do
      expect(subclass.from_degrees(90))
        .to be_an_instance_of(subclass)
    end
  end

  describe "#contain" do
    it "returns an instance of the argument's class" do
      expect(described_class.new(2, 3).contain(subclass.new(4, 5)))
        .to be_an_instance_of(subclass)
    end
  end

  context "when the subclass takes extra constructor arguments" do
    subject(:vector) { labeled.new(2.5, 3.5, "point") }

    let(:labeled) do
      stub_const("LabeledVector", Class.new(described_class) do
        attr_reader :label

        def self.build(x, y)
          new(x, y, "unlabeled")
        end

        def initialize(x, y, label)
          @label = label
          super(x, y)
        end

        def build(x, y)
          self.class.new(x, y, label)
        end
      end)
    end

    it { is_expected.to be_frozen }

    describe "#abs" do
      subject { vector.abs }

      it { is_expected.to be_an_instance_of(labeled) }
      it { is_expected.to be_frozen }
      its(:label) { is_expected.to eq("point") }
    end

    describe "#*" do
      subject { vector * 2 }

      its(:label) { is_expected.to eq("point") }
    end

    describe "#transform" do
      subject { vector.transform(Matrix[[0, -1], [1, 0]]) }

      its(:label) { is_expected.to eq("point") }
    end

    describe ".parse" do
      subject { labeled.parse("2x3") }

      it { is_expected.to be_an_instance_of(labeled) }
      its(:label) { is_expected.to eq("unlabeled") }
    end

    describe ".parse with a Vector" do
      subject { labeled.parse(Vector[2, 3]) }

      its(:label) { is_expected.to eq("unlabeled") }
    end

    describe ".from_angle" do
      subject { labeled.from_angle(0) }

      its(:label) { is_expected.to eq("unlabeled") }
    end
  end
end
