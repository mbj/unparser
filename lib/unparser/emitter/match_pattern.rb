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
        visit(pattern)
      end
    end # MatchPattern
  end # Emitter
end # Unparser
