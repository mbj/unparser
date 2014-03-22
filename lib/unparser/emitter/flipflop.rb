# encoding: utf-8

module Unparser
  class Emitter
    # Emitter for flip flops
    class FlipFlop < self

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
        visit_terminated(left)
        write(MAP.fetch(node.type))
        visit_terminated(right)
      end
    end # FlipFLop
  end # Emitter
end # Unparser
