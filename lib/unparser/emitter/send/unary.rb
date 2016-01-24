module Unparser
  class Emitter
    class Send
      # Emitter for unary sends
      #
      # rubocop:disable Style/HashSyntax
      # ^^ is false positive
      class Unary < self
        include Unterminated

      private

        MAP = IceNine.deep_freeze(
          :'-@' => '-',
          :'+@' => '+'
        )

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          name = selector
          write(MAP.fetch(name, name).to_s)
          if receiver.type.equal?(:int) && selector.equal?(:'+@') && receiver.children.first > 0
            write('+')
          end

          visit_on_side(receiver, :right)
        end

      end # Unary
    end # Send
  end # Emitter
end # Unparser
