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
        comment_enumerator.last_source_range_written = node.loc.begin
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
        visit_parentheses(arguments, T_PIPE, T_PIPE)
      end

    end # Block
  end # Emitter
end # Unparser
