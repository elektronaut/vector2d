# frozen_string_literal: true

require "spec_helper"
require "bigdecimal"

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

    [2, Math::PI / 2, Rational(1, 2), BigDecimal("1.5707963267948966")].each do |angle|
      context "with a #{angle.class} angle" do
        subject(:vector) { Vector2d.from_angle(angle) }

        it "returns float coordinates" do
          expect(vector.to_a).to all(be_an_instance_of(Float))
        end

        it "returns the angle it was given" do
          expect(vector.angle).to be_within(0.0001).of(angle.to_f)
        end
      end
    end

    [2, 2.0, Rational(2, 1), BigDecimal("2")].each do |length|
      context "with a #{length.class} length" do
        subject(:vector) { Vector2d.from_angle(0.9827, length) }

        it "returns float coordinates" do
          expect(vector.to_a).to all(be_an_instance_of(Float))
        end

        it "applies the length" do
          expect(vector.length).to be_within(0.0001).of(2.0)
        end
      end
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

  describe ".random" do
    it "returns a unit vector" do
      expect(Vector2d.random.length).to be_within(1e-12).of(1.0)
    end

    it "returns a vector of the given length" do
      expect(Vector2d.random(2.5).length).to be_within(1e-12).of(2.5)
    end

    it "returns floats" do
      expect(Vector2d.random.to_a).to all(be_a(Float))
    end

    it "returns a frozen vector" do
      expect(Vector2d.random).to be_frozen
    end

    it "stays within the unit circle over many draws" do
      lengths = 200.times.map { Vector2d.random.length }

      expect(lengths).to all(be_within(1e-12).of(1.0))
    end

    context "with a seeded Random" do
      it "repeats the same vector for the same seed" do
        first = Vector2d.random(random: Random.new(42))

        expect(Vector2d.random(random: Random.new(42))).to eq(first)
      end

      it "returns a different vector for a different seed" do
        expect(Vector2d.random(random: Random.new(42)))
          .not_to eq(Vector2d.random(random: Random.new(43)))
      end

      it "advances the sequence between draws" do
        random = Random.new(42)

        expect(Vector2d.random(random: random))
          .not_to eq(Vector2d.random(random: random))
      end

      it "applies the length" do
        expect(Vector2d.random(3.0, random: Random.new(42)).length)
          .to be_within(1e-12).of(3.0)
      end
    end

    context "with a stubbed Random" do
      let(:random) { instance_double(Random, rand: 0.25) }

      it "maps the draw onto a full turn" do
        expect(Vector2d.random(random: random))
          .to eq(Vector2d.from_angle(Math::PI / 2))
      end

      it "covers the whole circle" do
        allow(random).to receive(:rand).and_return(0.75)

        expect(Vector2d.random(random: random))
          .to eq(Vector2d.from_angle(1.5 * Math::PI))
      end
    end

    it "reaches every quadrant" do
      random = Random.new(1234)
      quadrants = 200.times.map do
        Vector2d.random(random: random).to_a.map(&:negative?)
      end

      expect(quadrants.uniq.size).to eq(4)
    end

    [2, 2.0, Rational(2, 1), BigDecimal("2")].each do |length|
      context "with a #{length.class} length" do
        subject(:vector) { Vector2d.random(length, random: Random.new(42)) }

        it "returns float coordinates" do
          expect(vector.to_a).to all(be_an_instance_of(Float))
        end

        it "applies the length" do
          expect(vector.length).to be_within(1e-12).of(2.0)
        end
      end
    end

    context "with a non-numeric length" do
      it "raises an error" do
        expect { Vector2d.random(nil) }.to(
          raise_error(ArgumentError, "not a valid coordinate: nil")
        )
      end
    end

    context "with a complex length" do
      it "raises an error" do
        expect { Vector2d.random(Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end
  end

  describe "the direction constants" do
    {
      zero: [0, 0],
      one: [1, 1],
      up: [0, 1],
      down: [0, -1],
      left: [-1, 0],
      right: [1, 0]
    }.each do |name, coordinates|
      describe ".#{name}" do
        subject(:vector) { Vector2d.public_send(name) }

        it "has the expected coordinates" do
          expect(vector.to_a).to eq(coordinates)
        end

        it "has integer coordinates" do
          expect(vector.to_a).to all(be_an(Integer))
        end

        it { is_expected.to be_frozen }
      end
    end

    it "points up along the positive y axis" do
      expect(Vector2d.up.angle).to be_within(1e-12).of(Math::PI / 2)
    end

    it "points down along the negative y axis" do
      expect(Vector2d.down.angle).to be_within(1e-12).of(-Math::PI / 2)
    end

    it "points right along the zero angle" do
      expect(Vector2d.right.angle).to eq(0.0)
    end

    it "points left along the straight angle" do
      expect(Vector2d.left.angle).to be_within(1e-12).of(Math::PI)
    end

    it "reverses up into down" do
      expect(Vector2d.up.reverse).to eq(Vector2d.down)
    end

    it "reverses left into right" do
      expect(Vector2d.left.reverse).to eq(Vector2d.right)
    end

    it "rotates right into up a quarter turn counterclockwise" do
      expect(Vector2d.right.rotate(Math::PI / 2).round)
        .to eq(Vector2d.up)
    end

    it "takes the perpendicular of right to up" do
      expect(Vector2d.right.perpendicular).to eq(Vector2d.up)
    end

    it "keeps integer coordinates through integer arithmetic" do
      expect((Vector2d.up * 2).to_a).to all(be_an(Integer))
    end

    it "widens to floats when a float is involved" do
      expect((Vector2d.up * 0.5).to_a).to all(be_a(Float))
    end

    it "returns an equal vector on every call" do
      first = Vector2d.zero

      expect(Vector2d.zero).to eql(first)
    end

    it "is the zero vector" do
      expect(Vector2d.zero).to be_zero
    end
  end
end
