module Unparser
  class Emitter
    class Send
      # Emitter for unary sends
      class Unary < self

      private

        MAP = IceNine.deep_freeze(
          '-@' => '-',
          '+@' => '+'
        )

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          name = selector
          write(MAP.fetch(name, name))
          emit_unambiguous_receiver
        end

      end # Unary
    end # Send
  end # Emitter
end # Unparser
