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

      # Test if this is a binary or unary operator expression
      #
      # @return [Boolean]
      #
      def operator?
        true
      end

      # Return the operator used (either :and, :or, :'&&', or :'||').
      #
      # @return [Symbol]
      #
      def operator
        MAP.fetch(node.type).to_sym
      end

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        visit_on_side(left, :left)
        write(WS, MAP.fetch(node.type), WS)
        visit_on_side(right, :right)
      end

    end # Binary
  end # Emitter
end # Unparser
