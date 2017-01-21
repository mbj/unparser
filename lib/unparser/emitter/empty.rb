module Unparser
  class Emitter

    # Emitter for artifical empty node
    class Empty < self

      handle :empty

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch; end

    end
  end
end # Unparser
