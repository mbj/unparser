module Unparser
  class Emitter
    # Emitter for return nodes
    class Return < self

      handle :return

      children :argument

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_RETURN)
        return unless argument
        visit_parentheses(argument)
      end

    end # Return
  end # Emitter
end # Unparser
