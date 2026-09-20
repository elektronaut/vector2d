# frozen_string_literal: true

require "ripper"

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
# the expression is expected to raise. An example spanning several
# lines, like a class definition, is evaluated as one expression.
module DocExamples
  ROOT = File.expand_path("../..", __dir__)
  COMMENT = /\A\s*#(?:\s|\z)/
  INDENTED = /\A\s*#\s{3}(\s*\S.*)\z/
  MARKER = /\A(.*?)\s*#\s*=>\s*(.+)\z/
  DEFINITION = /\A\s*def\s+(self\.)?([^\s(]+)/
  EXCEPTION = /\A(?:[A-Z]\w*::)*[A-Z]\w*Error\z/
  HASH_ROCKET = /:(\w+)=>/

  # A single line of an example. Setup lines have no expectation.
  Example = Struct.new(:location, :code, :expected) do
    def expectation? = !expected.nil?

    # Appends a line to an example that is not a complete expression yet.
    def continue(line, expected)
      self.code = "#{code}\n#{line}"
      self.expected = expected
    end

    def raises? = expected.match?(EXCEPTION)

    def exception = Object.const_get(expected)

    def pattern
      escaped = Regexp.escape(normalize(expected))
      Regexp.new("\\A#{escaped.gsub('\.\.') { '\d*' }}\\z")
    end

    def inspected(value) = normalize(value.inspect)

    private

    # Values are compared with whitespace removed, so the doc comments
    # are free to align the markers, and with hashes in the {key: value}
    # form Ruby 3.4 and up print.
    def normalize(inspected)
      inspected.delete(" ").gsub(HASH_ROCKET) { "#{Regexp.last_match(1)}:" }
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
        append(found, "#{file}:#{index + 1}", body) if body
      end
    end

    def append(found, location, body)
      expression, expected = body.match(MARKER)&.captures
      if expected && expression.empty?
        found.last.expected = expected
      elsif continues?(found.last)
        found.last.continue(expression || body, expected)
      else
        found << Example.new(location, expression || body, expected)
      end
    end

    def continues?(example) = example && !complete?(example.code)

    def complete?(code) = !Ripper.sexp(code).nil?

    # The method a doc comment sits above, for naming the example.
    def name(following)
      code = Array(following).map(&:first).find { |line| !line.strip.empty? }
      match = code&.match(DEFINITION)
      return "the examples" unless match

      "#{match[1] ? '.' : '#'}#{match[2]}"
    end
  end
end
