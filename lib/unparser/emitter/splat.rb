module Unparser
  class Emitter
    # Emitter for splats
    class Splat < self
      SPLAT = '*'.freeze

      handle :splat

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(SPLAT)
        child = first_child
        visit(child) if child
      end
    end
  end
end # Unparser
