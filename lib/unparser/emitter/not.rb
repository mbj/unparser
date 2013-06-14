module Unparser
  class Emitter
    # Emitter for 1.8 only not node
    class Not < self

      handle :not

      children :body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(O_NEG)
        visit(body)
      end

    end # Not
  end # Emitter
end # Unparser
