# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for regexp literals
    class Regexp < self

      handle :regexp

    private

      def dispatch
        writer.dispatch
      end

      def writer
        writer_with(Writer::Regexp, node:)
      end
      memoize :writer

    end # Regexp
  end # Emitter
end # Unparser
