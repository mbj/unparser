# frozen_string_literal: true

module Unparser
  class Emitter
    # Base class for primitive emitters
    class String < self
      children :value

      handle :str

    private

      # mutant:disable
      def dispatch
        if explicit_encoding && !value_encoding.equal?(explicit_encoding)
          if value_encoding.equal?(Encoding::UTF_8)
            write_utf8_escaped
          else
            write_reencoded
          end
        else
          write(value.inspect)
        end
      end

      def write_reencoded
        write('"')
        value.encode(explicit_encoding).bytes.each do |byte|
          write(byte.chr)
        end
        write('"')
      end

      def write_utf8_escaped
        write('"')
        value.each_codepoint do |codepoint|
          write("\\u{#{codepoint.to_s(16)}}")
        end
        write('"')
      end

      def value_encoding
        value.encoding
      end

    end # String
  end # Emitter
end # Unparser
