# encoding: utf-8

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
        if postcontrol?
          emit_postcontrol
        else
          emit_normal
        end
      end

      # Test for postcontrol
      #
      # @return [true]
      #   if repetition must be emitted as post control
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def postcontrol?
        return false unless body
        local_variable_scope.first_assignment_in_body_and_used_in_condition?(body, condition)
      end

      # Emit keyword
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_keyword
        write(MAP.fetch(node.type), WS)
      end

      # Emit embedded
      #
      # @return [undefned]
      #
      # @api private
      #
      def emit_normal
        emit_keyword
        visit_terminated(condition)
        emit_body
        k_end
      end

      # Emit postcontrol
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_postcontrol
        visit(body)
        ws
        emit_keyword
        visit(condition)
      end

    end # Repetition
  end # Emitter
end # Unparser
