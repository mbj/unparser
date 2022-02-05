# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for in pattern nodes
    class MatchPattern < self

      handle :match_pattern

      children :target, :pattern

      # Modern ast format emits `match_pattern`
      # node on single line pre 3.0, but 3.0+ uses `match_pattern_p`
      SYMBOL =
        if RUBY_VERSION < '3.0'
          ' in '
        else
          ' => '
        end

    private

      def dispatch
        visit(target)
        write(SYMBOL)
        visit(pattern)
      end
    end # MatchPattern
  end # Emitter
end # Unparser
