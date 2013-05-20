module Unparser
  class Emitter
    # Emitter for defined? nodes
    class Defined < self

      handle :defined?

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_DEFINED)
        parentheses do
          visit(first_child)
        end
      end

    end # Defined
  end # Emitter
end # Unparser
