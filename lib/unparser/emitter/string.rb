# frozen_string_literal: true

module Unparser
  class Emitter
    # Base class for primitive emitters
    class String < self
      children :value

      handle :str

    private

      def dispatch
        if explicit_encoding && !value.encoding.equal?(explicit_encoding)
          write_utf8_escaped
        else
          write(value.inspect)
        end
      end

      def write_utf8_escaped
        write('"')
        value.each_codepoint do |codepoint|
          write("\\u{#{codepoint.to_s(16)}}")
        end
        write('"')
      end

    end # String
  end # Emitter
end # Unparser
