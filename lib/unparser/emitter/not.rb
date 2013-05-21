module Unparser
  class Emitter
    class Not < self
      handle :not

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(O_NEG)
        visit(first_child)
      end

    end # Not
  end # Emitter
end # Unparser
