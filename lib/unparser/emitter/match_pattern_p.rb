# frozen_string_literal: true

module Unparser
  class Emitter
    class MatchPatternP < self

      handle :match_pattern_p

      children :target, :pattern

    private

      def dispatch
        visit(target)
        write(' in ')

        if n_array?(pattern)
          writer_with(Writer::Array, node: pattern).emit_compact
        else
          visit(pattern)
        end
      end
    end # MatchPatternP
  end # Emitter
end # Unparser
