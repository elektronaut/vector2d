# frozen_string_literal: true

RSpec.shared_examples "a parsed vector" do |x, y|
  it "receives the x property" do
    expect(subject.x).to eq(x)
  end

  it "receives the y property" do
    expect(subject.y).to eq(y)
  end
end
