module Unparser
  class Emitter
    # Emitter for next nodes
    class Next < self

      handle :next

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_NEXT)
      end

    end # Next
  end # Emitter
end # Unparser
