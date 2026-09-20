# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Constructors do
  describe ".from_angle" do
    context "with an angle of zero" do
      subject(:vector) { Vector2d.from_angle(0) }

      it_behaves_like "a parsed vector", [1.0, 0.0]
    end

    context "with a quarter turn" do
      subject(:vector) { Vector2d.from_angle(Math::PI / 2) }

      its(:x) { is_expected.to be_within(0.0001).of(0.0) }
      its(:y) { is_expected.to be_within(0.0001).of(1.0) }
    end

    context "with a negative angle" do
      subject(:vector) { Vector2d.from_angle(-Math::PI / 2) }

      its(:x) { is_expected.to be_within(0.0001).of(0.0) }
      its(:y) { is_expected.to be_within(0.0001).of(-1.0) }
    end

    context "without a length" do
      subject(:vector) { Vector2d.from_angle(0.9827) }

      its(:length) { is_expected.to be_within(0.0001).of(1.0) }
    end

    context "with a length" do
      subject(:vector) { Vector2d.from_angle(0.9827, 3.6055) }

      its(:length) { is_expected.to be_within(0.0001).of(3.6055) }
    end

    context "with an integer length" do
      subject(:vector) { Vector2d.from_angle(0, 2) }

      its(:x) { is_expected.to be_a(Float) }
      its(:y) { is_expected.to be_a(Float) }
    end

    it "is the inverse of #to_polar" do
      length, angle = Vector2d.new(2, 3).to_polar

      expect(Vector2d.from_angle(angle, length))
        .to eq(Vector2d.new(2.0, 3.0))
    end

    it "returns the angle it was given" do
      expect(Vector2d.from_angle(0.9827).angle)
        .to be_within(0.0001).of(0.9827)
    end

    context "with a non-numeric angle" do
      it "raises an error" do
        expect { Vector2d.from_angle("1") }.to(
          raise_error(ArgumentError, 'not a valid coordinate: "1"')
        )
      end
    end

    context "with a non-numeric length" do
      it "raises an error" do
        expect { Vector2d.from_angle(0, nil) }.to(
          raise_error(ArgumentError, "not a valid coordinate: nil")
        )
      end
    end

    context "with a complex angle" do
      it "raises an error" do
        expect { Vector2d.from_angle(Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end

    context "with a complex length" do
      it "raises an error" do
        expect { Vector2d.from_angle(0, Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end
  end
end
