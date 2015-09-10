module Unparser
  class Emitter
    # Emitter for undef nodes
    class Undef < self
      include Unterminated

      handle :undef

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_UNDEF, WS)
        delimited(children)
      end

    end # Undef
  end # Emitter
end # Unparser
