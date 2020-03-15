# frozen_string_literal: true

module Unparser
  class Emitter

    # Block emitter
    #
    # ignore :reek:RepeatedConditional
    class Numblock < self
      include Terminated

      handle :numblock

      children :target, :max, :body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        visit(target)
        write(WS, K_DO)
        emit_body
        k_end
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

    end # Block
  end # Emitter
end # Unparser
