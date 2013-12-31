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
        if children.any?
          head, *tail = children
          parentheses { visit(head) }
          tail.each do |node|
            write(', ')
            parentheses { visit(node) }
          end
        end
      end

    end # Return
  end # Emitter
end # Unparser
