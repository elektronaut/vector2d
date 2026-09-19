# frozen_string_literal: true

RSpec.shared_examples "a deprecated method" do |name, replacement|
  around do |example|
    enabled = Warning[:deprecated]
    Warning[:deprecated] = true
    example.run
    Warning[:deprecated] = enabled
  end

  it "warns that the method is deprecated" do
    expect { vector }
      .to output(/Vector2d##{name} is deprecated/).to_stderr
  end

  it "points at the replacement" do
    expect { vector }
      .to output(/#{Regexp.escape(replacement)}/).to_stderr
  end

  it "is silent when deprecation warnings are disabled" do
    Warning[:deprecated] = false
    expect { vector }.not_to output.to_stderr
  end
end
