# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for unless guards
    class UnlessGuard < self

      handle :unless_guard

      children :condition

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write('unless')
        ws
        visit(condition)
      end

    end # UnlessGuard
  end # Emitter
end # Unparser
