# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Arithmetic do
  subject(:vector) { Vector2d.new(2, 3) }

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

      its(:x) { is_expected.to be_a(Integer) }
      its(:y) { is_expected.to be_a(Integer) }
    end

    context "with a float" do
      subject(:vector) { Vector2d.new(2, 3) * 3.0 }

      it "multiplies both members" do
        expect(vector).to eq(Vector2d.new(6.0, 9.0))
      end

      its(:x) { is_expected.to be_a(Float) }
      its(:y) { is_expected.to be_a(Float) }
    end

    context "with a complex number" do
      it "raises a TypeError" do
        expect { Vector2d.new(2, 3) * Complex(1, 2) }.to(
          raise_error(TypeError, "Complex can't be coerced into Vector2d")
        )
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

      its(:x) { is_expected.to be_a(Integer) }
      its(:y) { is_expected.to be_a(Integer) }
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

      its(:x) { is_expected.to be_a(Integer) }
      its(:y) { is_expected.to be_a(Integer) }
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

      its(:x) { is_expected.to be_a(Integer) }
      its(:y) { is_expected.to be_a(Integer) }
    end
  end

  describe "-@" do
    it "reverses the vector" do
      expect(-Vector2d.new(2, 3)).to eq(Vector2d.new(-2, -3))
    end

    it "is the same as #reverse" do
      expect(-vector).to eq(vector.reverse)
    end

    it "returns the original vector when applied twice" do
      expect(-(-vector)).to eq(vector)
    end
  end

  describe "+@" do
    it "returns the vector unchanged" do
      expect(+Vector2d.new(2, 3)).to eq(Vector2d.new(2, 3))
    end

    it "returns the same object" do
      expect(+vector).to be(vector)
    end
  end

  describe "#reverse" do
    it "reverses the vector" do
      expect(vector.reverse).to eq(Vector2d.new(-2, -3))
    end
  end
end
