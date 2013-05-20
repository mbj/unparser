module Unparser
  class Emitter
    class Break < self

      handle :break

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_BREAK)
        arguments = first_child
        return unless arguments
        parentheses do
          visit(arguments)
        end
      end

    end # Break
  end # Emitter
end # Unparser
