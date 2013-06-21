module Unparser
  class Emitter

    # Block emitter
    class Block < self

      handle :block

      children :send, :arguments, :body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        visit(send)
        write(WS, K_DO)
        emit_block_arguments
        emit_body
        k_end
      end

      # Emit arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_block_arguments
        return if arguments.children.empty?
        ws
        parentheses(T_PIPE, T_PIPE) do
          visit(arguments)
        end
      end

    end # Block
  end # Emitter
end # Unparser
