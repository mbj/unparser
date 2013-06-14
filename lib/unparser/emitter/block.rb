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
        indented { emit_body }
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
        parentheses(O_PIPE, O_PIPE) do
          visit(arguments)
        end
      end

      # Emit body
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_body
        visit(body)
      end

    end # Block
  end # Emitter
end # Unparser
