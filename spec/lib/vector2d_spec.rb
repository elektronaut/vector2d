# frozen_string_literal: true

require "spec_helper"
require "matrix"

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

  describe ".parse" do
    context "with fixnum argument" do
      subject(:vector) { described_class.parse(2) }

      it_behaves_like "a parsed vector", [2, 2]
    end

    context "with two arguments, fixnum" do
      subject(:vector) { described_class.parse(1, 2) }

      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with two arguments, float" do
      subject(:vector) { described_class.parse(1.0, 2.0) }

      it_behaves_like "a parsed vector", [1.0, 2.0]
    end

    context "with string argument, first omitted" do
      subject(:vector) { described_class.parse("x200") }

      it_behaves_like "a parsed vector", [0, 200]
    end

    context "with string argument, second omitted" do
      subject(:vector) { described_class.parse("200x") }

      it_behaves_like "a parsed vector", [200, 0]
    end

    context "with string argument, fixnum" do
      subject(:vector) { described_class.parse("1x2") }

      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with string argument, float" do
      subject(:vector) { described_class.parse("1.0x2.0") }

      it_behaves_like "a parsed vector", [1.0, 2.0]
    end

    context "with string argument, negative" do
      subject(:vector) { described_class.parse("-1x-2") }

      it_behaves_like "a parsed vector", [-1, -2]
    end

    context "with string argument, explicitly positive" do
      subject(:vector) { described_class.parse("+1x+2") }

      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with string argument, no leading zero" do
      subject(:vector) { described_class.parse(".5x.25") }

      it_behaves_like "a parsed vector", [0.5, 0.25]
    end

    context "with string argument, uppercase separator" do
      subject(:vector) { described_class.parse("1X2") }

      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with string argument, comma separator" do
      subject(:vector) { described_class.parse("1, 2") }

      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with string argument, surrounding whitespace" do
      subject(:vector) { described_class.parse(" 1 x 2 ") }

      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with string argument, mixing integer and float" do
      subject(:vector) { described_class.parse("1x2.0") }

      its(:x) { is_expected.to be_an(Integer) }
      its(:y) { is_expected.to be_a(Float) }
    end

    context "with a malformed string argument" do
      it "raises an error" do
        expect { described_class.parse("1.2.3x4") }.to(
          raise_error(ArgumentError, 'not a valid string input: "1.2.3x4"')
        )
      end
    end

    context "with a string argument holding three coordinates" do
      it "raises an error" do
        expect { described_class.parse("1x2x3") }.to(
          raise_error(ArgumentError, 'not a valid string input: "1x2x3"')
        )
      end
    end

    context "with a string argument holding no coordinates" do
      it "raises an error" do
        expect { described_class.parse("foo") }.to(
          raise_error(ArgumentError, 'not a valid string input: "foo"')
        )
      end
    end

    context "with array argument" do
      subject(:vector) { described_class.parse([1, 2]) }

      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with single element array argument" do
      subject(:vector) { described_class.parse([5]) }

      it_behaves_like "a parsed vector", [5, 5]
    end

    context "with hash argument, symbol keys" do
      subject(:vector) { described_class.parse(x: 1, y: 2) }

      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with hash argument, string keys" do
      subject(:vector) { described_class.parse("x" => 1, "y" => 2) }

      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with vector argument" do
      subject(:vector) { described_class.parse(described_class.new(1, 2)) }

      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with a Vector argument" do
      subject(:vector) { described_class.parse(Vector[1, 2]) }

      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with a Vector argument of the wrong size" do
      it "raises an error" do
        expect { described_class.parse(Vector[1, 2, 3]) }.to(
          raise_error(ArgumentError, "expected 2 coordinates, got 3")
        )
      end
    end

    context "with a column Matrix argument" do
      subject(:vector) { described_class.parse(Matrix[[1], [2]]) }

      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with a row Matrix argument" do
      subject(:vector) { described_class.parse(Matrix[[1, 2]]) }

      it_behaves_like "a parsed vector", [1, 2]
    end

    context "with a Matrix argument of the wrong shape" do
      it "raises an error" do
        expect { described_class.parse(Matrix[[1, 2], [3, 4]]) }.to(
          raise_error(ArgumentError, "expected a 2x1 or 1x2 matrix, got 2x2")
        )
      end
    end

    context "with a Vector argument holding a complex" do
      it "raises an error" do
        expect { described_class.parse(Vector[Complex(1, 2), 3]) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end

    context "with a Matrix argument holding a complex" do
      it "raises an error" do
        expect { described_class.parse(Matrix[[Complex(1, 2)], [3]]) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end

    context "with nil argument" do
      it "raises an error" do
        expect { described_class.parse(nil) }.to(
          raise_error(ArgumentError, "not a valid coordinate: nil")
        )
      end
    end

    context "with a non-numeric argument" do
      it "raises an error" do
        expect { described_class.parse(:foo) }.to(
          raise_error(ArgumentError, "not a valid coordinate: :foo")
        )
      end
    end

    context "with rational argument" do
      subject(:vector) { described_class.parse(Rational(1, 2), 3) }

      it_behaves_like "a parsed vector", [Rational(1, 2), 3]
    end

    context "with complex argument" do
      it "raises an error" do
        expect { described_class.parse(Complex(1, 2)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end

    context "with a complex coordinate among two arguments" do
      it "raises an error" do
        expect { described_class.parse(Complex(1, 2), 3) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end

    context "with complex argument that has a zero imaginary part" do
      it "raises an error" do
        expect { described_class.parse(Complex(1, 0)) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+0i)")
        )
      end
    end

    context "with array argument holding a complex" do
      it "raises an error" do
        expect { described_class.parse([Complex(1, 2), 3]) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end

    context "with hash argument holding a complex" do
      it "raises an error" do
        expect { described_class.parse(x: Complex(1, 2), y: 3) }.to(
          raise_error(ArgumentError, "not a valid coordinate: (1+2i)")
        )
      end
    end

    context "with a non-numeric second argument" do
      it "raises an error" do
        expect { described_class.parse(1, "2") }.to(
          raise_error(ArgumentError, 'not a valid coordinate: "2"')
        )
      end
    end

    context "with nil as the second argument" do
      it "raises an error" do
        expect { described_class.parse(5, nil) }.to(
          raise_error(ArgumentError, "not a valid coordinate: nil")
        )
      end
    end

    context "with nil as the second argument of the global method" do
      it "raises an error" do
        expect { Vector2d(5, nil) }.to(
          raise_error(ArgumentError, "not a valid coordinate: nil")
        )
      end
    end

    context "with empty hash argument" do
      it "raises an error" do
        expect { described_class.parse({}) }.to(
          raise_error(ArgumentError, "not a valid coordinate: nil")
        )
      end
    end

    context "with hash argument missing y" do
      it "raises an error" do
        expect { described_class.parse(x: 1) }.to(
          raise_error(ArgumentError, "not a valid coordinate: nil")
        )
      end
    end

    context "with hash argument holding a non-numeric value" do
      it "raises an error" do
        expect { described_class.parse(x: 1, y: "2") }.to(
          raise_error(ArgumentError, 'not a valid coordinate: "2"')
        )
      end
    end

    context "with array argument holding nil" do
      it "raises an error" do
        expect { described_class.parse([1, nil]) }.to(
          raise_error(ArgumentError, "not a valid coordinate: nil")
        )
      end
    end

    context "with array argument of the wrong size" do
      it "raises an error" do
        expect { described_class.parse([1, 2, 3]) }.to(
          raise_error(ArgumentError, "expected 1 or 2 coordinates, got 3")
        )
      end
    end

    context "with hash argument, nil symbol key falling back to string key" do
      subject(:vector) { described_class.parse(x: nil, "x" => 1, y: 2) }

      it_behaves_like "a parsed vector", [1, 2]
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
