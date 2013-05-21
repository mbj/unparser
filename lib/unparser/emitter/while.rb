module Unparser
  class Emitter
    class While < self

      handle :while

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_WHILE, WS)
        visit(first_child)
        indented { visit(children[1]) }
        k_end
      end

    end # While
  end # Emitter
end # Unparser
