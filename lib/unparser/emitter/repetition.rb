module Unparser
  class Emitter

    # Emitter for postconditions
    class Post < self

      handle :while_post, :until_post

      children :condition, :body

      MAP = {
        while_post: K_WHILE,
        until_post: K_UNTIL
      }.freeze

      handle(*MAP.keys)

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        visit(body)
        write(WS, MAP.fetch(node.type), WS)
        visit(condition)
      end
    end

    # Base class for while and until emitters
    class Repetition < self

      MAP = {
        while: K_WHILE,
        until: K_UNTIL
      }.freeze

      handle(*MAP.keys)

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
