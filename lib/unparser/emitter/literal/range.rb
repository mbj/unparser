module Unparser
  class Emitter
    class Literal
      # Abstract base class for literal range emitter
      class Range < self
        include Unterminated

        TOKENS = IceNine.deep_freeze(
          irange: '..',
          erange: '...'
        )

        handle(*TOKENS.keys)

        children :begin_node, :end_node

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          visit(begin_node)
          write(TOKENS.fetch(node.type))
          visit(end_node)
        end

      end # Range
    end # Literal
  end # Emitter
end # Unparser
