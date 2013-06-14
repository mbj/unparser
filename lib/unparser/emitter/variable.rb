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

      children :parent, :name

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_parent
        write(name.to_s)
      end

      # Emit parent
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_parent
        return unless parent
        visit(parent)
        if parent.type != :cbase
          write(O_DCL)
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
