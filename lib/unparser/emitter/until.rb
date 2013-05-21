module Unparser
  class Emitter
    # Emitter for until nodes
    class Until < self

      handle :until

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_UNTIL, WS)
        visit(first_child)
        indented { visit(children[1]) }
        k_end
      end

    end # Until
  end # Emitter
end # Unparser
