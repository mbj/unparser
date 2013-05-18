module Unparser
  class Emitter

    # Block emitter
    class Block < self

      handle :block

      K_DO = ' do'.freeze
      PIPE_OPEN = ' |'.freeze
      PIPE_CLOSE = '|'.freeze

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_send
        write(K_DO)
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
        parentheses(PIPE_OPEN, PIPE_CLOSE) do
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
        return if body.type == :nil
        visit(body)
      end

    end # Block
  end # Emitter
end # Unparser
