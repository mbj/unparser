module Unparser
  class Emitter

    # Base class for while and until emitters
    class Repetition < self

      MAP = {
        :while => K_WHILE,
        :until => K_UNTIL
      }.freeze

      handle *MAP.keys

      children :condition, :body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(MAP.fetch(node.type), WS)
        visit(condition)
        emit_body
        k_end
      end

    end # Repetition
  end # Emitter
end # Unparser
