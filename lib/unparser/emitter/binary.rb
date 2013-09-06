module Unparser
  class Emitter
    # Base class for binary emitters
    class Binary < self

      children :left, :right

      MAP = {
        :or => T_OR,
        :and => T_AND
      }.freeze

      handle(*MAP.keys)

      # Test if expression is terminated
      #
      # @return [false]
      #
      # @api private
      #
      def terminated?
        false
      end

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        visit_terminated(left)
        write(WS, MAP.fetch(node.type), WS)
        visit_terminated(right)
      end

    end # Binary
  end # Emitter
end # Unparser
