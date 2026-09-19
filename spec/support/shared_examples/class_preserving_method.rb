# frozen_string_literal: true

RSpec.shared_examples "a class preserving method" do |method, *args|
  describe "##{method}" do
    it "returns an instance of the receiver's class" do
      expect(vector.public_send(method, *args))
        .to be_an_instance_of(vector.class)
    end
  end
end
