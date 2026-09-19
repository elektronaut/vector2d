# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Calculations do
  subject(:vector) { Vector2d.new(2, 3) }

  describe ".cross_product" do
    let(:v1) { Vector2d.new(2, 3) }
    let(:v2) { Vector2d.new(4, 5) }

    it "calculates the cross product between two vectors" do
      expect(Vector2d.cross_product(v1, v2)).to eq(-2.0)
    end
  end

  describe ".dot_product" do
    let(:v1) { Vector2d.new(2, 3) }
    let(:v2) { Vector2d.new(4, 5) }

    it "calculates the dot product between two vectors" do
      expect(Vector2d.dot_product(v1, v2)).to eq(23)
    end
  end

  describe ".angle_between" do
    let(:v1) { Vector2d.new(2, 3) }
    let(:v2) { Vector2d.new(4, 5) }

    it "calculates the angle between two vectors" do
      expect(Vector2d.angle_between(v1, v2)).to be_within(0.0001).of(-0.0867)
    end

    it "signs the angle by direction of rotation" do
      expect(Vector2d.angle_between(v2, v1)).to be_within(0.0001).of(0.0867)
    end

    it "ignores the magnitude of the vectors" do
      expect(
        Vector2d.angle_between(v1 * 1000, v2 * 0.001)
      ).to be_within(0.0001).of(-0.0867)
    end

    it "returns zero for identical vectors" do
      expect(Vector2d.angle_between(v1, v1)).to eq(0.0)
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

    it "handles parallel vectors of any magnitude" do
      angles = 1000.times.map do |i|
        v = Vector2d.new((i + 1) * 0.37, (i + 1) * -1.13)
        Vector2d.angle_between(v, v * ((i % 7) + 1))
      end
      expect(angles).to all(be_within(1e-12).of(0.0))
    end
  end

  describe "*" do
    context "with vector" do
      subject(:vector) { Vector2d.new(2, 3) * Vector2d.new(3, 4) }

      it "multiplies the vectors" do
        expect(vector).to eq(Vector2d.new(6, 12))
      end
    end

    context "with number" do
      subject(:vector) { Vector2d.new(2, 3) * 3 }

      it "multiplies both members" do
        expect(vector).to eq(Vector2d.new(6, 9))
      end
    end
  end

  describe "/" do
    context "with vector" do
      subject(:vector) { Vector2d.new(6, 12) / Vector2d.new(2, 3) }

      it "divides the vectors" do
        expect(vector).to eq(Vector2d.new(3, 4))
      end
    end

    context "with number" do
      subject(:vector) { Vector2d.new(6, 12) / 3 }

      it "divides both members" do
        expect(vector).to eq(Vector2d.new(2, 4))
      end
    end
  end

  describe "+" do
    context "with vector" do
      subject(:vector) { Vector2d.new(2, 3) + Vector2d.new(3, 4) }

      it "adds the vectors" do
        expect(vector).to eq(Vector2d.new(5, 7))
      end
    end

    context "with number" do
      subject(:vector) { Vector2d.new(2, 3) + 2 }

      it "adds to both members" do
        expect(vector).to eq(Vector2d.new(4, 5))
      end
    end
  end

  describe "-" do
    context "with vector" do
      subject(:vector) { Vector2d.new(3, 5) - Vector2d.new(1, 2) }

      it "subtracts the vectors" do
        expect(vector).to eq(Vector2d.new(2, 3))
      end
    end

    context "with number" do
      subject(:vector) { Vector2d.new(2, 3) - 2 }

      it "subtracts from both members" do
        expect(vector).to eq(Vector2d.new(0, 1))
      end
    end
  end

  describe "#cross_product" do
    let(:comp) { Vector2d.new(3, 4) }

    it "calulates the cross product" do
      expect(
        vector.cross_product(comp)
      ).to eq(Vector2d.cross_product(vector, comp))
    end
  end

  describe "#distance" do
    let(:comp) { Vector2d.new(3, 4) }

    it "returns the distance between two vectors" do
      expect(vector.distance(comp)).to be_within(0.0001).of(1.4142)
    end
  end

  describe "#distance_squared" do
    let(:comp) { Vector2d.new(5, 6) }

    it "returns the squared distance between two vectors" do
      expect(vector.distance_squared(comp)).to eq(18)
    end
  end

  describe "#squared_distance" do
    let(:comp) { Vector2d.new(5, 6) }

    it "is an alias of #distance_squared" do
      expect(vector.squared_distance(comp)).to eq(18)
    end
  end

  describe "#dot_product" do
    let(:comp) { Vector2d.new(3, 4) }

    it "calulates the dot product" do
      expect(vector.dot_product(comp)).to eq(Vector2d.dot_product(vector, comp))
    end
  end

  describe "#angle_between" do
    let(:comp) { Vector2d.new(3, 4) }

    it "calculates the angle between vectors" do
      expect(
        vector.angle_between(comp)
      ).to eq(Vector2d.angle_between(vector, comp))
    end
  end
end
