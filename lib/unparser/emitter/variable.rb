module Unparser
  class Emitter

    # Emitter for various variable accesses
    class Variable < self
      include Terminated

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
      include Terminated

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
        write(T_DCL) unless scope.type.equal?(:cbase)
      end
    end

    # Emitter for nth_ref nodes (regexp captures)
    class NthRef < self
      include Terminated

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
