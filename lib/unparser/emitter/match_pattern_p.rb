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
        visit(pattern)
      end
    end # MatchPatternP
  end # Emitter
end # Unparser
