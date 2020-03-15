# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for in pattern nodes
    class InPattern < self

      handle :in_pattern

      children :target, :unless_guard, :branch, :else_branch

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write('in')
        ws
        visit(target)
        if unless_guard
          ws
          visit(unless_guard)
        end
        if branch
          ws
          write('then')
          ws
          visit(branch)
        end
      end
    end # InPattern
  end # Emitter
end # Unparser
