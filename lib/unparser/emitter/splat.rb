module Unparser
  class Emitter
    # Emitter for splats
    class Splat < self

      handle :splat

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(O_SPLAT)
        child = first_child
        visit(child) if child
      end
    end
  end
end # Unparser
