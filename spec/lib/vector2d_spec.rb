require 'spec_helper'

describe Vector2d do
  subject(:vector) { Vector2d.new(2, 3) }

  shared_examples "a vector constructor" do |x, y|
    it "receives the x and y properties" do
      expect(subject.x).to eq(x)
      expect(subject.y).to eq(y)
    end
  end

  describe "new" do
    context "with two arguments, fixnum" do
      subject(:vector) { Vector2d.new(1, 2) }
      it_behaves_like "a vector constructor", [1, 2]
    end

    context "with two arguments, float" do
      subject(:vector) { Vector2d.new(1.0, 2.0) }
      it_behaves_like "a vector constructor", [1.0, 2.0]
    end

    context "with string argument, fixnum" do
      subject(:vector) { Vector2d.new("1x2") }
      it_behaves_like "a vector constructor", [1, 2]
    end

    context "with string argument, float" do
      subject(:vector) { Vector2d.new("1.0x2.0") }
      it_behaves_like "a vector constructor", [1.0, 2.0]
    end

    context "with array argument" do
      subject(:vector) { Vector2d.new([1, 2]) }
      it_behaves_like "a vector constructor", [1, 2]
    end

    context "with hash argument, symbol keys" do
      subject(:vector) { Vector2d.new({:x => 1, :y => 2}) }
      it_behaves_like "a vector constructor", [1, 2]
    end

    context "with hash argument, string keys" do
      subject(:vector) { Vector2d.new({'x' => 1, 'y' => 2}) }
      it_behaves_like "a vector constructor", [1, 2]
    end

    context "with vector argument" do
      subject(:vector) { Vector2d.new(Vector2d.new(1, 2)) }
      it_behaves_like "a vector constructor", [1, 2]
    end
  end

  describe ".cross_product" do
    let(:v1) { Vector2d.new(2, 3) }
    let(:v2) { Vector2d.new(4, 5) }
    it "calculates the cross product between two vectors" do
      expect(Vector2d.cross_product(v1, v2)).to be_within(0.0001).of(-2.0)
    end
  end

  describe ".dot_product" do
    let(:v1) { Vector2d.new(2, 3) }
    let(:v2) { Vector2d.new(4, 5) }
    it "calculates the dot product between two vectors" do
      expect(Vector2d.dot_product(v1, v2)).to be_within(0.0001).of(23.0)
    end
  end

  describe ".angle_between" do
    let(:v1) { Vector2d.new(2, 3) }
    let(:v2) { Vector2d.new(4, 5) }
    it "calculates the angle between two vectors" do
      expect(Vector2d.angle_between(v1, v2)).to be_within(0.0001).of(0.0867)
    end
  end

  describe "#==" do
    subject { vector == comp }

    context "with both arguments equal" do
      let(:comp) { Vector2d.new(2, 3) }
      it { should be_true }
    end

    context "with x differing" do
      let(:comp) { Vector2d.new(3, 3) }
      it { should be_false }
    end

    context "with y differing" do
      let(:comp) { Vector2d.new(2, 4) }
      it { should be_false }
    end
  end

  describe "#to_s" do
    it "renders a string" do
      expect(vector.to_s).to eq('2.0x3.0')
    end
  end

  describe "#length" do
    it "calculates the length" do
      expect(vector.length).to be_within(0.0001).of(3.6055)
    end
  end

  describe "#length_squared" do
    it "calculates the squared length" do
      expect(vector.length_squared).to be_within(0.0001).of(13.0)
    end
  end

  describe "#resize" do
    subject(:resized) { vector.resize(2.0) }
    it "modifies the vector length" do
      expect(resized.length).to be_within(0.0001).of(2.0)
      expect(resized.x).to be_within(0.0001).of(1.1094)
      expect(resized.y).to be_within(0.0001).of(1.6641)
    end
  end

  describe "#normalize" do
    it "normalizes the vector" do
      expect(vector.normalize.x).to be_within(0.0001).of(0.5547)
      expect(vector.normalize.y).to be_within(0.0001).of(0.8320)
    end
  end

  describe "#round" do
    subject(:vector) { Vector2d.new(2.3, 3.6) }
    it "rounds the vector" do
      expect(vector.round).to eq(Vector2d.new(2, 4))
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

  describe "#perpendicular" do
    it "returns a perpendicular vector" do
      expect(vector.perpendicular).to eq(Vector2d.new(-3, 2))
    end
  end

  describe "#distance" do
    let(:comp) { Vector2d.new(3, 4) }
    it "returns the distance between two vectors" do
      expect(vector.distance(comp)).to be_within(0.0001).of(1.4142)
    end
  end

  describe "#distance_sq" do
    let(:comp) { Vector2d.new(5, 6) }
    it "returns the squared distance between two vectors" do
      expect(vector.distance_sq(comp)).to be_within(0.0001).of(18.0)
    end
  end

  describe "#angle" do
    it "returns the angle" do
      expect(vector.angle).to be_within(0.0001).of(0.9827)
    end
  end

  describe "#aspect_ratio" do
    it "returns the aspect_ratio" do
      expect(vector.aspect_ratio).to be_within(0.0001).of(0.6667)
    end
  end

  describe "#truncate" do
    context "when argument is longer than length" do
      let(:arg) { 5.0 }
      it "does not change the length" do
        expect(vector.truncate(arg).length).to be_within(0.0001).of(3.6055)
      end
    end
    context "when argument is shorter than length" do
      let(:arg) { 2.5 }
      it "changes the length" do
        expect(vector.truncate(arg).length).to be_within(0.0001).of(arg)
      end
    end
  end

  describe "#reverse" do
    it "reverses the vector" do
      expect(vector.reverse).to eq(Vector2d.new(-2, -3))
    end
  end

  describe "#cross_product" do
    let(:comp) { Vector2d.new(3, 4) }
    it "calulates the cross product" do
      expect(vector.cross_product(comp)).to eq(Vector2d.cross_product(vector, comp))
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
      expect(vector.angle_between(comp)).to eq(Vector2d.angle_between(vector, comp))
    end
  end

  describe "#contrain_both" do
    let(:original) { Vector2d.new(300, 300) }
    subject(:vector) { original.constrain_both(comp) }

    context "when scaling by height" do
      let(:comp) { Vector2d.new(200, 150) }
      it "should fit within the other vector" do
        expect(vector.x).to be_within(0.0001).of(150)
        expect(vector.y).to be_within(0.0001).of(150)
      end
    end

    context "when scaling by width" do
      let(:comp) { Vector2d.new(150, 200) }
      it "should fit within the other vector" do
        expect(vector.x).to be_within(0.0001).of(150)
        expect(vector.y).to be_within(0.0001).of(150)
      end
    end
  end

  describe "#contrain_one" do
    let(:original) { Vector2d.new(300, 300) }
    subject(:vector) { original.constrain_one(comp) }

    context "when width is largest" do
      let(:comp) { Vector2d.new(200, 150) }
      it "should be the same width" do
        expect(vector.x).to be_within(0.0001).of(200)
        expect(vector.y).to be_within(0.0001).of(200)
      end
    end

    context "when height is largest" do
      let(:comp) { Vector2d.new(150, 200) }
      it "should be the same height" do
        expect(vector.x).to be_within(0.0001).of(200)
        expect(vector.y).to be_within(0.0001).of(200)
      end
    end
  end
end