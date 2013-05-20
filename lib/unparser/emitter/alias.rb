module Unparser
  class Emitter
    # Emitter for alias nodes
    class Alias < self

      handle :alias

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_ALIAS, WS)
        visit(first_child)
        write(WS)
        visit(children[1])
      end

    end # Alias
  end # Emitter
end # Unparser
