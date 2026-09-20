# frozen_string_literal: true

class Vector2d
  # The warning issued by the methods deprecated for 3.0. Each of them
  # names its replacement, and forwards to it.
  module Deprecation
    private

    # Warns that a method is deprecated. Silent unless deprecation
    # warnings are enabled, either with <tt>Warning[:deprecated] = true</tt>
    # or by running Ruby with <tt>-w</tt>.
    def warn_deprecated(message)
      warn(message, uplevel: 2, category: :deprecated)
    end
  end
end
