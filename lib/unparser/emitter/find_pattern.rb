# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for in pattern nodes
    class FindPattern < self
      handle :find_pattern

    private

      def dispatch
        write('[')
        delimited(children)
        write(']')
      end
    end # FindPattern
  end # Emitter
end # Unparser
