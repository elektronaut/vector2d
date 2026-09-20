# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Degrees do
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
  end
end
