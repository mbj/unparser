# encoding: utf-8

module Unparser
  class Emitter

    # Emitter for various variable accesses
    class Variable < self

      handle :ivar, :lvar, :cvar, :gvar, :back_ref

      children :name

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(name.to_s)
      end

    end # Access

    # Emitter for constant access
    class Const < self

      handle :const

      children :scope, :name

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_scope
        write(name.to_s)
      end

      # Emit parent
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_scope
        return unless scope
        visit(scope)
        if scope.type != :cbase
          write(T_DCL)
        end
      end
    end

    # Emitter for nth_ref nodes (regexp captures)
    class NthRef < self
      PREFIX = '$'.freeze
      handle :nth_ref

      children :name

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(PREFIX)
        write(name.to_s)
      end

    end # NthRef

  end # Emitter
end # Unparser
