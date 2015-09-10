module Unparser
  class Emitter
    # Emitter for flip flops
    class FlipFlop < self
      include Unterminated

      MAP = IceNine.deep_freeze(
        iflipflop: '..',
        eflipflop: '...'
      ).freeze

      handle(*MAP.keys)

      children :left, :right

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        visit(left)
        write(MAP.fetch(node.type))
        visit(right)
      end
    end # FlipFLop
  end # Emitter
end # Unparser
