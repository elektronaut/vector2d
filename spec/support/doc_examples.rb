# frozen_string_literal: true

require "ripper"

# Extracts the runnable examples from the documentation.
#
# The doc comments under lib/ and the fenced Ruby blocks in the README
# are read the same way. Lines carrying a "# =>" marker assert on the
# value of the expression to their left, the rest are setup, and the
# examples in one block share a binding:
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
  MARKER = /\A(.*?)\s*#\s*=>\s*(.+)\z/
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

    # Values are compared with whitespace removed, so the documentation
    # is free to align the markers, and with hashes in the {key: value}
    # form Ruby 3.4 and up print.
    def normalize(inspected)
      inspected.delete(" ").gsub(HASH_ROCKET) { "#{Regexp.last_match(1)}:" }
    end
  end

  # The examples from a single doc comment or README section.
  Block = Struct.new(:file, :line, :name, :examples)

  class << self
    def blocks = Comments.blocks + Markdown.blocks

    # A block built from its code lines, or nil if none of them assert
    # on anything.
    def block(file, line, name, lines)
      examples = examples(file, lines)
      return unless examples.any?(&:expectation?)

      Block.new(file, line, name, examples)
    end

    private

    def examples(file, lines)
      lines.each_with_object([]) do |(body, index), found|
        append(found, "#{file}:#{index + 1}", body)
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
  end
end
