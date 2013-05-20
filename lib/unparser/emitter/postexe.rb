module Unparser
  class Emitter
    # Emitter for postexe nodes
    class Preexe < self

      handle :preexe

    private

      # Perfrom dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_PREEXE, WS)
        parentheses(*CURLY_BRACKETS) do
          indented { visit(first_child) }
        end
      end

    end # Postexe

    # Emitter for postexe nodes
    class Postexe < self

      handle :postexe

      POSTEXE_PARENS = IceNine.deep_freeze(%w({ }))

    private

      # Perfrom dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_POSTEXE, WS)
        parentheses(*CURLY_BRACKETS) do
          indented { visit(first_child) }
        end
      end

    end # Postexe
  end # Emitter
end # Unparser
