module Unparser
  class Emitter
    # Emitter for break nodes
    class Break < self

      handle :break

      children :arguments

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_BREAK)
        return unless arguments
        parentheses do
          visit(arguments)
        end
      end

    end # Break
  end # Emitter
end # Unparser
