module Unparser
  class Emitter

    # Base class for while and until emitters 
    class Repetition < self

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(self.class::KEYWORD, WS)
        visit(first_child)
        indented { visit(children[1]) }
        k_end
      end

      # Emitter for until nodes
      class Until < self

        KEYWORD = K_UNTIL

        handle :until

      private

      end # Until

      # Emiter for while nodes
      class While < self

        handle :while

        KEYWORD = K_WHILE

      end # While

    end # Repetition
  end # Emitter
end # Unparser
