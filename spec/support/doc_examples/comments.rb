# frozen_string_literal: true

module DocExamples
  # The examples in the doc comments under lib/. An example is an
  # indented line inside a comment, and one comment is one block, named
  # after the method it sits above.
  #
  # Tag blocks are skipped. A block runs from the first tag at the left
  # margin of the comment to the next blank comment line, so the type
  # lists in @param and @return are not mistaken for examples.
  module Comments
    COMMENT = /\A\s*#(?:\s|\z)/
    INDENTED = /\A\s*#\s{3}(\s*\S.*)\z/
    DEFINITION = /\A\s*def\s+(self\.)?([^\s(]+)/
    TAG = /\A\s*#\s@/
    BLANK = /\A\s*#\s*\z/

    class << self
      def blocks
        Dir[File.join(ROOT, "lib/**/*.rb")].flat_map { |path| parse(path) }
      end

      private

      def parse(path)
        chunks = File.readlines(path, chomp: true).each_with_index.to_a
                     .chunk { |line, _| line.match?(COMMENT) }.to_a
        chunks.each_with_index.filter_map do |(comment, lines), index|
          block(path, lines, chunks.dig(index + 1, 1)) if comment
        end
      end

      def block(path, lines, following)
        DocExamples.block(path.delete_prefix("#{ROOT}/"), lines.first[1] + 1,
                          name(following), code(lines))
      end

      def code(lines)
        untagged(lines).filter_map do |line, index|
          body = line[INDENTED, 1]
          [body, index] if body
        end
      end

      # Drops the tag blocks, each running from its first tag to the
      # next blank comment line.
      def untagged(lines)
        tagged = false
        lines.reject do |line, _|
          tagged = true if line.match?(TAG)
          tagged &&= !line.match?(BLANK)
        end
      end

      # The method a doc comment sits above, for naming the example.
      def name(following)
        code = Array(following).map(&:first).find { |line| !line.strip.empty? }
        match = code&.match(DEFINITION)
        return "the examples" unless match

        "#{match[1] ? '.' : '#'}#{match[2]}"
      end
    end
  end
end
