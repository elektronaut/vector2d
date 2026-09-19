# frozen_string_literal: true

# Extracts the runnable examples from the doc comments in lib/.
#
# An example is an indented line inside a comment. Lines carrying a
# "# =>" marker assert on the value of the expression to their left,
# the rest are setup. The examples in one comment share a binding:
#
#   v = Vector2d(2, 3)
#   v.length # => 3.6055..
#
# A marker on a line of its own applies to the line above it. A
# trailing ".." stands in for any digits, and an exception class means
# the expression is expected to raise.
module DocExamples
  ROOT = File.expand_path("../..", __dir__)
  COMMENT = /\A\s*#(?:\s|\z)/
  INDENTED = /\A\s*#\s{3}(\S.*)\z/
  MARKER = /\A(.*?)\s*#\s*=>\s*(.+)\z/
  DEFINITION = /\A\s*def\s+(self\.)?([^\s(]+)/
  EXCEPTION = /\A(?:[A-Z]\w*::)*[A-Z]\w*Error\z/

  # A single line of an example. Setup lines have no expectation.
  Example = Struct.new(:location, :code, :expected) do
    def expectation? = !expected.nil?

    def raises? = expected.match?(EXCEPTION)

    def exception = Object.const_get(expected)

    # Values are compared with whitespace removed, so the doc comments
    # are free to align the markers.
    def pattern
      escaped = Regexp.escape(expected.delete(" "))
      Regexp.new("\\A#{escaped.gsub('\.\.') { '\d*' }}\\z")
    end
  end

  # The examples from a single doc comment.
  Block = Struct.new(:file, :line, :name, :examples)

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
      file = path.delete_prefix("#{ROOT}/")
      examples = extract(file, lines)
      return unless examples.any?(&:expectation?)

      Block.new(file, lines.first[1] + 1, name(following), examples)
    end

    def extract(file, lines)
      lines.each_with_object([]) do |(line, index), found|
        body = line[INDENTED, 1]
        next unless body

        expression, expected = body.match(MARKER)&.captures
        if expected && expression.empty?
          found.last.expected = expected
        else
          found << Example.new("#{file}:#{index + 1}", expression || body, expected)
        end
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
