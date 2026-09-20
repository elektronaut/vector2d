# frozen_string_literal: true

module DocExamples
  # The examples in the fenced Ruby blocks in the README.
  #
  # One section, from a heading to the next, is one block. The fenced
  # blocks under a heading share a binding, the way the README reads,
  # where a vector set up in one paragraph is used by the next.
  module Markdown
    FILE = "README.md"
    HEADING = /\A##\s+(.+)\z/
    FENCE = /\A```/
    RUBY_FENCE = /\A```ruby\s*\z/

    class << self
      def blocks
        lines = File.readlines(File.join(ROOT, FILE), chomp: true)
        sections(lines.each_with_index.to_a)
          .filter_map { |section| block(section) }
      end

      private

      def sections(lines)
        lines.slice_before { |line, _| line.match?(HEADING) }
      end

      def block(section)
        DocExamples.block(FILE, section.first[1] + 1, name(section),
                          code(section))
      end

      def name(section)
        heading = section.first[0][HEADING, 1]
        heading ? "the #{heading} section" : "the examples"
      end

      # The lines inside the ```ruby fences, with the blank ones dropped.
      def code(section)
        fenced(section).reject { |line, _| line.strip.empty? }
      end

      def fenced(lines)
        lines.slice_before { |line, _| line.match?(FENCE) }
             .select { |chunk| chunk.first[0].match?(RUBY_FENCE) }
             .flat_map { |chunk| chunk.drop(1) }
      end
    end
  end
end
