module Unparser
  class Emitter
    # Emitter for return nodes
    class Return < self

      handle :return

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_RETURN)
        emit_argument
      end

      # Emit argument
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_argument
        argument = first_child
        return unless argument
        parentheses do
          visit(argument)
        end
      end

    end # Return
  end # Emitter
end # Unparser
