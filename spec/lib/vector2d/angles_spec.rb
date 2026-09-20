# frozen_string_literal: true

require "spec_helper"
require "bigdecimal"

describe Vector2d::Angles do
  subject(:vector) { Vector2d.new(2, 3) }

  describe ".radians" do
    it "converts degrees to radians" do
      expect(Vector2d.radians(90)).to be_within(0.0001).of(Math::PI / 2)
    end

    it "converts negative angles" do
      expect(Vector2d.radians(-90)).to be_within(0.0001).of(-Math::PI / 2)
    end

    it "returns a float" do
      expect(Vector2d.radians(0)).to be_an_instance_of(Float)
    end

    it "is the inverse of .degrees" do
      expect(Vector2d.degrees(Vector2d.radians(37.5))).to be_within(0.0001).of(37.5)
    end

    it "raises an ArgumentError unless the angle is a real number" do
      expect { Vector2d.radians(Complex(1, 2)) }
        .to raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
    end

    [90, 90.0, Rational(90, 1), BigDecimal("90")].each do |angle|
      context "with a #{angle.class} angle" do
        subject(:radians) { Vector2d.radians(angle) }

        it { is_expected.to be_an_instance_of(Float) }

        it "converts the angle" do
          expect(radians).to be_within(0.0001).of(Math::PI / 2)
        end
      end
    end
  end

  describe ".degrees" do
    it "converts radians to degrees" do
      expect(Vector2d.degrees(Math::PI / 2)).to be_within(0.0001).of(90.0)
    end

    it "converts negative angles" do
      expect(Vector2d.degrees(-Math::PI / 2)).to be_within(0.0001).of(-90.0)
    end

    it "returns a float" do
      expect(Vector2d.degrees(0)).to be_an_instance_of(Float)
    end

    it "raises an ArgumentError unless the angle is a real number" do
      expect { Vector2d.degrees(Complex(1, 2)) }
        .to raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
    end

    [1, 1.0, Rational(1, 1), BigDecimal("1")].each do |angle|
      context "with a #{angle.class} angle" do
        subject(:degrees) { Vector2d.degrees(angle) }

        it { is_expected.to be_an_instance_of(Float) }

        it "converts the angle" do
          expect(degrees).to be_within(0.0001).of(57.2957)
        end
      end
    end
  end

  describe ".from_degrees" do
    it "creates a vector from an angle" do
      expect(Vector2d.from_degrees(90).y).to be_within(0.0001).of(1.0)
    end

    it "defaults to unit length" do
      expect(Vector2d.from_degrees(30).length).to be_within(0.0001).of(1.0)
    end

    it "takes a length" do
      expect(Vector2d.from_degrees(30, 2.0).length).to be_within(0.0001).of(2.0)
    end

    it "matches .from_angle with the angle converted" do
      expect(Vector2d.from_degrees(30, 2.0))
        .to eq(Vector2d.from_angle(Vector2d.radians(30), 2.0))
    end

    it "raises an ArgumentError unless the angle is a real number" do
      expect { Vector2d.from_degrees(Complex(1, 2)) }
        .to raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
    end

    it "raises an ArgumentError unless the length is a real number" do
      expect { Vector2d.from_degrees(30, Complex(1, 2)) }
        .to raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
    end

    [45, 45.0, Rational(45, 1), BigDecimal("45")].each do |angle|
      context "with a #{angle.class} angle" do
        subject(:vector) { Vector2d.from_degrees(angle) }

        it "returns float coordinates" do
          expect(vector.to_a).to all(be_an_instance_of(Float))
        end

        it "converts the angle" do
          expect(vector.angle_in_degrees).to be_within(0.0001).of(45.0)
        end
      end
    end

    [2, 2.0, Rational(2, 1), BigDecimal("2")].each do |length|
      context "with a #{length.class} length" do
        subject(:vector) { Vector2d.from_degrees(45, length) }

        it "returns float coordinates" do
          expect(vector.to_a).to all(be_an_instance_of(Float))
        end

        it "applies the length" do
          expect(vector.length).to be_within(0.0001).of(2.0)
        end
      end
    end
  end

  describe ".angle_to" do
    let(:v1) { Vector2d.new(2, 3) }
    let(:v2) { Vector2d.new(4, 5) }

    it "calculates the angle from one vector to another" do
      expect(Vector2d.angle_to(v1, v2)).to be_within(0.0001).of(-0.0867)
    end

    it "signs the angle by direction of rotation" do
      expect(Vector2d.angle_to(v2, v1)).to be_within(0.0001).of(0.0867)
    end

    it "ignores the magnitude of the vectors" do
      expect(
        Vector2d.angle_to(v1 * 1000, v2 * 0.001)
      ).to be_within(0.0001).of(-0.0867)
    end

    it "returns zero for identical vectors" do
      expect(Vector2d.angle_to(v1, v1)).to eq(0.0)
    end

    it "returns zero for parallel vectors" do
      expect(Vector2d.angle_to(v1, v1 * 2.3)).to eq(0.0)
    end

    it "returns PI for antiparallel vectors" do
      expect(Vector2d.angle_to(v1, v1 * -2.3)).to eq(Math::PI)
    end

    it "returns zero for a zero length vector" do
      expect(Vector2d.angle_to(v1, Vector2d.new(0, 0))).to eq(0.0)
    end

    it "stays within -PI..PI" do
      angles = 360.times.map do |i|
        Vector2d.angle_to(v1, v1.rotate(i * Math::PI / 180))
      end
      expect(angles).to all(be_between(-Math::PI, Math::PI))
    end

    it "handles parallel vectors of any magnitude" do
      angles = 1000.times.map do |i|
        v = Vector2d.new((i + 1) * 0.37, (i + 1) * -1.13)
        Vector2d.angle_to(v, v * ((i % 7) + 1))
      end
      expect(angles).to all(be_within(1e-12).of(0.0))
    end
  end

  describe ".angle_between" do
    let(:v1) { Vector2d.new(2, 3) }
    let(:v2) { Vector2d.new(4, 5) }

    it "calculates the unsigned angle between two vectors" do
      expect(Vector2d.angle_between(v1, v2)).to be_within(0.0001).of(0.0867)
    end

    it "ignores the order of the arguments" do
      expect(Vector2d.angle_between(v2, v1))
        .to eq(Vector2d.angle_between(v1, v2))
    end

    it "ignores the magnitude of the vectors" do
      expect(
        Vector2d.angle_between(v1 * 1000, v2 * 0.001)
      ).to be_within(0.0001).of(0.0867)
    end

    it "returns zero for parallel vectors" do
      expect(Vector2d.angle_between(v1, v1 * 2.3)).to eq(0.0)
    end

    it "returns PI for antiparallel vectors" do
      expect(Vector2d.angle_between(v1, v1 * -2.3)).to eq(Math::PI)
    end

    it "returns zero for a zero length vector" do
      expect(Vector2d.angle_between(v1, Vector2d.new(0, 0))).to eq(0.0)
    end

    it "stays within 0..PI" do
      angles = 360.times.map do |i|
        Vector2d.angle_between(v1, v1.rotate(i * Math::PI / 180))
      end
      expect(angles).to all(be_between(0, Math::PI))
    end
  end

  describe "#angle" do
    it "returns the angle" do
      expect(vector.angle).to be_within(0.0001).of(0.9827)
    end
  end

  describe "#angle_in_degrees" do
    it "returns the angle in degrees" do
      expect(vector.angle_in_degrees).to be_within(0.0001).of(56.3099)
    end

    it "is signed" do
      expect(Vector2d.new(0, -1).angle_in_degrees).to be_within(0.0001).of(-90.0)
    end

    it "matches #angle converted" do
      expect(vector.angle_in_degrees).to eq(Vector2d.degrees(vector.angle))
    end

    it "is zero for the zero vector" do
      expect(Vector2d.new(0, 0).angle_in_degrees).to eq(0.0)
    end

    [[0, 1], [0.0, 1.0], [Rational(0, 1), Rational(1, 1)],
     [BigDecimal("0"), BigDecimal("1")]].each do |(x, y)|
      context "with #{y.class} coordinates" do
        subject(:degrees) { Vector2d.new(x, y).angle_in_degrees }

        it { is_expected.to be_an_instance_of(Float) }

        it "returns the angle in degrees" do
          expect(degrees).to be_within(0.0001).of(90.0)
        end
      end
    end
  end

  describe "#angle_to" do
    let(:comp) { Vector2d.new(3, 4) }

    it "calculates the angle to the other vector" do
      expect(
        vector.angle_to(comp)
      ).to eq(Vector2d.angle_to(vector, comp))
    end

    it "coerces the argument" do
      expect(vector.angle_to([3, 4])).to eq(vector.angle_to(comp))
    end
  end

  describe "#angle_between" do
    let(:comp) { Vector2d.new(3, 4) }

    it "calculates the angle between vectors" do
      expect(
        vector.angle_between(comp)
      ).to eq(Vector2d.angle_between(vector, comp))
    end

    it "coerces the argument" do
      expect(vector.angle_between([3, 4])).to eq(vector.angle_between(comp))
    end
  end

  describe "#angle_with" do
    let(:comp) { Vector2d.new(3, 4) }

    it "is an alias of #angle_between" do
      expect(vector.angle_with(comp)).to eq(vector.angle_between(comp))
    end
  end

  describe "#to_polar" do
    it "returns the length first" do
      expect(vector.to_polar.first).to be_within(0.0001).of(3.6055)
    end

    it "returns the angle second" do
      expect(vector.to_polar.last).to be_within(0.0001).of(0.9827)
    end

    it "is the inverse of Vector2d.from_angle" do
      length, angle = vector.to_polar

      expect(Vector2d.from_angle(angle, length))
        .to eq(Vector2d.new(2.0, 3.0))
    end

    context "with the zero vector" do
      let(:vector) { Vector2d.new(0, 0) }

      it "returns zero length and angle" do
        expect(vector.to_polar).to eq([0.0, 0.0])
      end
    end
  end

  describe "#rotate" do
    subject { vector.rotate(rotation).round(3) }

    let(:vector) { Vector2d.new(1, 0) }

    context "when roating by PI" do
      let(:rotation) { Math::PI }

      it { is_expected.to eq(Vector2d.new(-1, 0)) }
    end

    context "when roating by PI/2" do
      let(:rotation) { Math::PI / 2 }

      it { is_expected.to eq(Vector2d.new(0, 1)) }
    end

    context "when roating by -PI/2" do
      let(:rotation) { -Math::PI / 2 }

      it { is_expected.to eq(Vector2d.new(0, -1)) }
    end

    context "when roating by PI/4" do
      let(:rotation) { Math::PI / 4 }

      it { is_expected.to eq(Vector2d.new(0.707, 0.707)) }
    end

    context "with a complex angle" do
      it "raises an error" do
        expect { vector.rotate(Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end
  end

  describe "#rotate_degrees" do
    it "rotates the vector counterclockwise" do
      expect(vector.rotate_degrees(90)).to eq(Vector2d.new(-3.0, 2.0))
    end

    it "rotates clockwise for a negative angle" do
      expect(vector.rotate_degrees(-90).x).to be_within(0.0001).of(3.0)
    end

    it "matches #rotate with the angle converted" do
      expect(vector.rotate_degrees(30)).to eq(vector.rotate(Vector2d.radians(30)))
    end

    it "leaves the length alone" do
      expect(vector.rotate_degrees(30).length).to be_within(0.0001).of(vector.length)
    end

    it "raises an ArgumentError unless the angle is a real number" do
      expect { vector.rotate_degrees(Complex(1, 2)) }
        .to raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
    end

    [90, 90.0, Rational(90, 1), BigDecimal("90")].each do |angle|
      context "with a #{angle.class} angle" do
        subject(:rotated) { vector.rotate_degrees(angle) }

        it "returns float coordinates" do
          expect(rotated.to_a).to all(be_an_instance_of(Float))
        end

        it "rotates the vector" do
          expect(rotated).to eq(Vector2d.new(-3.0, 2.0))
        end
      end
    end
  end

  describe "#rotate_around" do
    subject { vector.rotate_around(center, Math::PI / 2).round(3) }

    let(:vector) { Vector2d.new(2, 1) }
    let(:center) { Vector2d.new(1, 1) }

    it { is_expected.to eq(Vector2d.new(1, 2)) }

    context "when the center is the origin" do
      let(:center) { Vector2d.new(0, 0) }

      it { is_expected.to eq(vector.rotate(Math::PI / 2).round(3)) }
    end

    context "when the center is the vector itself" do
      let(:center) { vector }

      it { is_expected.to eq(vector) }
    end

    context "with a coercible center" do
      let(:center) { [1, 1] }

      it { is_expected.to eq(Vector2d.new(1, 2)) }
    end
  end

  describe "#perpendicular" do
    it "returns a perpendicular vector" do
      expect(vector.perpendicular).to eq(Vector2d.new(-3, 2))
    end

    it "turns the same way as #rotate" do
      expect(vector.perpendicular.round(3))
        .to eq(vector.rotate(Math::PI / 2).round(3))
    end
  end

  describe "#perpendicular_cw" do
    it "returns a perpendicular vector" do
      expect(vector.perpendicular_cw).to eq(Vector2d.new(3, -2))
    end

    it "turns the opposite way from #perpendicular" do
      expect(vector.perpendicular_cw).to eq(vector.perpendicular.reverse)
    end
  end
end
