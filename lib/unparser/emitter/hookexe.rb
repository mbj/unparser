module Unparser
  class Emitter
    # Base class for pre and postexe emitters
    class Hookexe < self

      MAP = {
        preexe:  K_PREEXE,
        postexe: K_POSTEXE
      }.freeze

      handle(*MAP.keys)

      children :body

    private

      # Perfrom dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(MAP.fetch(node.type), WS)
        parentheses(*CURLY_BRACKETS) do
          emit_body
        end
      end

    end # Hookexe
  end # Emitter
end # Unparser
