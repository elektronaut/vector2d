# frozen_string_literal: true

require "spec_helper"

describe Vector2d do
  DocTags.methods.each do |method|
    describe method.path do
      it "documents every parameter" do
        expect(DocTags.undocumented_parameters(method)).to be_empty
      end

      it "documents what it returns" do
        expect(method.tags(:return)).not_to be_empty
      end

      it "avoids type names that are too vague", :aggregate_failures do
        DocTags.tags(method).each do |tag|
          expect(tag.types & DocTags::FORBIDDEN).to be_empty, tag.to_s
        end
      end

      it "names every coordinate type", :aggregate_failures do
        DocTags.coordinate_tags(method).each do |tag|
          expect(tag.missing(DocTags::COORDINATE)).to be_empty, tag.to_s
        end
      end

      it "names the parse union in full", :aggregate_failures do
        DocTags.parse_union_tags(method).each do |tag|
          expect(tag.missing(DocTags::COERCIBLE)).to be_empty, tag.to_s
        end
      end
    end
  end

  it "tags every method that warns as deprecated" do
    expect(DocTags.untagged_deprecations).to be_empty
  end

  it "closes every doc comment with its tag block" do
    expect(DocTags.prose_after_tags).to be_empty
  end
end
