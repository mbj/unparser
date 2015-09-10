module Unparser
  class Emitter

    # Base class for special match node emitters
    class Match < self
      include Unterminated

      OPERATOR = '=~'.freeze

      # Emitter for match with local variable assignment
      class Lvasgn < self
        handle :match_with_lvasgn

        children :regexp, :lvasgn

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          visit(regexp)
          write(WS, OPERATOR, WS)
          visit(lvasgn)
        end

      end # Lvasgn

      # Emitter for match current line
      class CurrentLine < self
        handle :match_current_line

        children :regexp

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          visit(regexp)
        end

      end # CurrentLine

    end # Match
  end # Emitter
end # Unparser
