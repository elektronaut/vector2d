# frozen_string_literal: true

require "spec_helper"

describe Vector2d do
  # Examples are evaluated with +self+ set to a vector, so the ones
  # documenting private instance methods need no receiver.
  def new_scope = Vector2d.new(0, 0).instance_eval { binding }

  def failure_message(doc) = "#{doc.location}: #{doc.code}"

  def expect_documented(scope, doc)
    return scope.eval(doc.code) unless doc.expectation?
    return expect_raise(scope, doc) if doc.raises?

    expect(scope.eval(doc.code).inspect.delete(" "))
      .to match(doc.pattern), failure_message(doc)
  end

  def expect_raise(scope, doc)
    expect { scope.eval(doc.code) }
      .to raise_error(doc.exception), failure_message(doc)
  end

  DocExamples.blocks.each do |block|
    it "matches the output shown for #{block.name} " \
       "(#{block.file}:#{block.line})", :aggregate_failures do
      scope = new_scope
      block.examples.each { |doc| expect_documented(scope, doc) }
    end
  end
end
