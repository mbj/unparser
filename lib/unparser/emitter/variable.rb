# frozen_string_literal: true

module Unparser
  class Emitter

    # Emitter for various variable accesses
    class Variable < self
      handle :ivar, :lvar, :cvar, :gvar, :back_ref

      children :name

    private

      def dispatch
        write_loc(name.to_s, node.location.name.to_range)
      end

    end # Access

    # Emitter for constant access
    class Const < self
      handle :const

      children :scope, :name

    private

      def dispatch
        emit_scope
        write_loc(name.to_s, node.location.name.to_range)
      end

      def emit_scope
        return unless scope

        visit(scope)
        write_loc('::', node.location.double_colon.to_range) unless n_cbase?(scope)
      end
    end

    # Emitter for nth_ref nodes (regexp captures)
    class NthRef < self
      PREFIX = '$'.freeze
      handle :nth_ref

      children :name

    private

      def dispatch
        write_loc([PREFIX, name.to_s], node.location.expression.to_range)
      end

    end # NthRef

  end # Emitter
end # Unparser
