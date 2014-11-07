# encoding: utf-8

module Unparser
  class Emitter
    # Emitter for for nodes
    class For < self
      include Terminated

      handle :for

      children :condition, :assignment, :body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_FOR, WS)
        emit_condition
        emit_body
        k_end
      end

      # Emit assignment
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_condition
        visit_plain(condition)
        write(WS, K_IN, WS)
        visit(assignment)
        write(WS, K_DO)
      end

    end # For
  end # Emitter
end # Unparser
