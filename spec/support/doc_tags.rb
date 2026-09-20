# frozen_string_literal: true

require "yard"

# The type vocabulary the doc tags are written in.
#
# YARD tags are the only place a type is declared, so a union that
# loses a member in one comment is a silent error. These are the
# canonical spellings, and the checks below hold every tag to them.
module DocTags
  ROOT = File.expand_path("../..", __dir__)

  # Coordinates are the concrete real classes. Numeric is wrong: to_i,
  # to_f and nan? are defined on these four, not on Numeric.
  COORDINATE = %w[Integer Float Rational BigDecimal].freeze

  # Everything Vector2d.parse accepts, written out once in the
  # +coercible+ macro in lib/vector2d.rb.
  COERCIBLE = %w[Vector2d Array String Hash Integer Float Rational
                 BigDecimal ::Vector ::Matrix].freeze

  # The members of the parse union that are not coordinates. Naming
  # two of them is what marks a parameter as taking the whole union.
  SHAPES = %w[Vector2d Array String Hash ::Vector ::Matrix].freeze

  # Numeric spans Complex, which is not a coordinate, and misses the
  # methods the coordinate types are used for.
  FORBIDDEN = %w[Numeric].freeze
  TYPE_NAME = /(?:::)?[A-Z]\w*/
  TAG = /\A\s*#\s@/
  DEPRECATED = /\A\s*#\s@deprecated\b/
  CONTINUATION = /\A\s*#\s{2,}\S/
  COMMENT = /\A\s*#(?:\s|\z)/

  # One tag, with its type list flattened to the names it mentions.
  Tag = Struct.new(:path, :kind, :name, :types) do
    def to_s = [path, "@#{kind}", name].compact.join(" ")

    def count(union) = (union & types).size

    def missing(union) = union - types
  end

  class << self
    def methods
      load_registry
      YARD::Registry.all(:method)
                    .select { |m| m.visibility == :public }
                    .sort_by(&:path)
    end

    # Every parameter the method takes, keywords included.
    def parameters(method)
      method.parameters.map { |name, _| name.to_s.delete("*&:") }
            .reject(&:empty?)
    end

    # The parameters with no @param, counting the ones inside an
    # @overload.
    def undocumented_parameters(method)
      documented = method.tags(:param) +
                   method.tags(:overload).flat_map { |o| o.tags(:param) }
      parameters(method) - documented.map(&:name)
    end

    def tags(method)
      collect(method, method) +
        method.tags(:overload).flat_map { |o| collect(method, o) }
    end

    # The tags naming more than one coordinate type, which have to
    # name all four. One on its own is a type in its own right, as the
    # Integer #ceil rounds to is.
    def coordinate_tags(method)
      tags(method).select { |tag| tag.count(COORDINATE) > 1 }
    end

    # The tags taking anything Vector2d.parse accepts, which have to
    # name the whole union.
    def parse_union_tags(method)
      tags(method).select do |tag|
        tag.kind == :param && tag.count(SHAPES) > 1
      end
    end

    # Methods warning about their own deprecation without saying so in
    # a tag.
    def untagged_deprecations
      load_registry
      YARD::Registry.all(:method).select do |method|
        method.name != :warn_deprecated &&
          method.source.to_s.include?("warn_deprecated") &&
          method.tag(:deprecated).nil?
      end.map(&:path)
    end

    # Comment lines that come after the tag block of their doc
    # comment. Tags close a comment, and the example extractor reads
    # them as running to the end of it, so prose after them would go
    # missing and type lists before them would be read as code.
    # @deprecated is the exception, and opens a comment.
    def prose_after_tags
      sources.flat_map do |file, lines|
        comment_blocks(lines).flat_map { |block| stray(file, block) }
      end
    end

    private

    def comment_blocks(lines)
      lines.each_with_index.chunk { |line, _| line.match?(COMMENT) }
           .select(&:first).map(&:last)
    end

    def stray(file, block)
      start = block.index { |line, _| line.match?(TAG) && !line.match?(DEPRECATED) }
      return [] unless start

      block[start..]
        .reject { |line, _| line.match?(TAG) || line.match?(CONTINUATION) }
        .map { |_, index| "#{file}:#{index + 1}" }
    end

    def collect(method, holder)
      %i[param return].flat_map do |kind|
        holder.tags(kind).map do |tag|
          Tag.new(method.path, kind, tag.name,
                  Array(tag.types).join(",").scan(TYPE_NAME).uniq)
        end
      end
    end

    def sources
      files.map { |path| [path.delete_prefix("#{ROOT}/"), File.readlines(path, chomp: true)] }
    end

    # lib/vector2d.rb first, so the macros it defines are known by the
    # time the modules using them are parsed.
    def files
      Dir[File.join(ROOT, "lib/**/*.rb")].sort_by { |path| [path.count("/"), path] }
    end

    def load_registry
      return if @loaded

      YARD::Registry.clear
      YARD.parse(files, [], YARD::Logger::ERROR)
      @loaded = true
    end
  end
end
