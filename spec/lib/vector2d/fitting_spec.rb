# frozen_string_literal: true

require "spec_helper"

describe Vector2d::Fitting do
  let(:original) { Vector2d.new(300, 300) }

  describe "#contain" do
    subject(:vector) { original.contain(comp) }

    context "when vector is smaller" do
      let(:comp) { Vector2d.new(150, 100) }

      its(:x) { is_expected.to eq(150) }
      its(:y) { is_expected.to eq(100) }
    end

    context "when vector is wider" do
      let(:comp) { Vector2d.new(400, 300) }

      its(:x) { is_expected.to eq(300) }
      its(:y) { is_expected.to eq(225) }
    end

    context "when vector is higher" do
      let(:comp) { Vector2d.new(300, 400) }

      its(:x) { is_expected.to eq(225) }
      its(:y) { is_expected.to eq(300) }
    end
  end

  describe "#fit" do
    subject(:vector) { original.fit(comp) }

    context "when scaling by height" do
      let(:comp) { Vector2d.new(200, 150) }

      its(:x) { is_expected.to eq(150) }
      its(:y) { is_expected.to eq(150) }
    end

    context "when scaling by width" do
      let(:comp) { Vector2d.new(150, 200) }

      its(:x) { is_expected.to eq(150) }
      its(:y) { is_expected.to eq(150) }
    end
  end

  describe "#fit_either" do
    subject(:vector) { original.fit_either(comp) }

    let(:original) { Vector2d.new(300, 300) }

    context "when width is largest" do
      let(:comp) { Vector2d.new(200, 150) }

      its(:x) { is_expected.to eq(200) }
      its(:y) { is_expected.to eq(200) }
    end

    context "when height is largest" do
      let(:comp) { Vector2d.new(150, 200) }

      its(:x) { is_expected.to eq(200) }
      its(:y) { is_expected.to eq(200) }
    end
  end
end
