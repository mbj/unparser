module Unparser
  class Emitter
    # Emitter for for nodes
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
        emit_condition
        emit_body
        k_end
      end

      # Emit assignment
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_condition
        visit(first_child)
        write(WS, K_IN, WS)
        visit(children[1])
        write(WS, K_DO)
      end

      # Emit body
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_body
        indented { visit(children[2]) }
      end

    end # For
  end # Emitter
end # Unparser
