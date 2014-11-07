# encoding: utf-8

module Unparser
  class Emitter
    # Base class for binary emitters
    class Binary < self
      include Unterminated

      children :left, :right

      MAP = {
        or:  T_OR,
        and: T_AND
      }.freeze

      handle(*MAP.keys)

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        visit(left)
        write(WS, MAP.fetch(node.type), WS)
        visit(right)
      end

    end # Binary
  end # Emitter
end # Unparser
