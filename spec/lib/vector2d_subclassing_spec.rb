# frozen_string_literal: true

require "spec_helper"

describe Vector2d do
  subject(:vector) { subclass.new(2.5, 3.5) }

  let(:subclass) { stub_const("SubVector", Class.new(described_class)) }

  it_behaves_like "a class preserving method", :*, 2
  it_behaves_like "a class preserving method", :/, 2
  it_behaves_like "a class preserving method", :+, 2
  it_behaves_like "a class preserving method", :-, 2

  it_behaves_like "a class preserving method", :to_i_vector
  it_behaves_like "a class preserving method", :to_f_vector

  it_behaves_like "a class preserving method", :fit, 10
  it_behaves_like "a class preserving method", :fit_either, 10

  it_behaves_like "a class preserving method", :ceil
  it_behaves_like "a class preserving method", :clamp, 0, 10
  it_behaves_like "a class preserving method", :clamp_length, 1.0
  it_behaves_like "a class preserving method", :floor
  it_behaves_like "a class preserving method", :normalize
  it_behaves_like "a class preserving method", :perpendicular
  it_behaves_like "a class preserving method", :resize, 2.0
  it_behaves_like "a class preserving method", :reverse
  it_behaves_like "a class preserving method", :rotate, Math::PI
  it_behaves_like "a class preserving method", :round

  describe "#contain" do
    it "returns an instance of the argument's class" do
      expect(described_class.new(2, 3).contain(subclass.new(4, 5)))
        .to be_an_instance_of(subclass)
    end
  end
end
