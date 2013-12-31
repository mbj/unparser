module Unparser
  class Emitter
    # Emitter for return nodes
    class Return < self

      handle :return

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_RETURN)
        if children.any?
          ws
          delimited(children)
        end
      end

    end # Return
  end # Emitter
end # Unparser
