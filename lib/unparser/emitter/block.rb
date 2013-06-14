module Unparser
  class Emitter

    # Block emitter
    class Block < self

      handle :block

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_send
        write(WS, K_DO)
        emit_block_arguments
        indented { emit_body }
        k_end
      end

      # Emit send
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_send
        visit(first_child)
      end

      # Emit arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_block_arguments
        arguments = children[1]
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
        body = children[2]
        visit(body)
      end

    end # Block
  end # Emitter
end # Unparser
