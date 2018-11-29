# frozen_string_literal: true

module Unparser
  class Emitter

    # Block emitter
    #
    # ignore :reek:RepeatedConditional
    class Block < self
      include Terminated

      handle :block

      children :target, :arguments, :body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_target
        write(WS, K_DO)
        emit_block_arguments unless stabby_lambda?
        emit_body
        k_end
      end

      # Emit target
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_target
        visit(target)

        if stabby_lambda?
          parentheses { visit(arguments) }
        end
      end

      # Test if we are emitting a stabby lambda
      #
      # @return [Boolean]
      #
      # @api private
      #
      def stabby_lambda?
        target.type.equal?(:lambda)
      end

      # Emit arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_block_arguments
        return if arguments.children.empty?

        ws
        visit_parentheses(arguments, T_PIPE, T_PIPE)
      end

    end # Block
  end # Emitter
end # Unparser
