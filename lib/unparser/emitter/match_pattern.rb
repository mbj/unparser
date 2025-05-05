# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for in pattern nodes
    class MatchPattern < self

      handle :match_pattern

      children :target, :pattern

    private

      def dispatch
        visit(target)
        write(' => ')

        if n_array?(pattern)
          writer_with(Writer::Array, node: pattern).emit_compact
        else
          visit(pattern)
        end
      end
    end # MatchPattern
  end # Emitter
end # Unparser
