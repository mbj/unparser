# frozen_string_literal: true

module Unparser
  class Emitter
    # Dynamic string emitter
    class DStr < self

      handle :dstr

    private

      def dispatch
        dstr_writer.dispatch
      end

      def dstr_writer
        writer_with(Writer::DynamicString, node:)
      end
      memoize :dstr_writer

    end # DStr
  end # Emitter
end # Unparser
