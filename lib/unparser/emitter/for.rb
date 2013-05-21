module Unparser
  class Emitter
    class For < self

      handle :for

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_FOR, WS)
        visit(first_child)
        write(WS, K_IN, WS)
        visit(children[1])
        write(WS, K_DO)
        indented { visit(children[2]) }
        k_end
      end

    end # For
  end # Emitter
end # Unparser
