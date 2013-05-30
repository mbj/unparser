module Unparser
  class Emitter

    # Emitter for various variable accesses
    class Variable < self

      handle :ivar, :lvar, :cvar, :gvar, :back_ref

    private
     
      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(first_child.to_s)
      end

    end # Access

    # Emitter for constant access
    class Const < self

      handle :const

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_parent
        write(children.last.to_s)
      end

      # Emit parent
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_parent
        parent = first_child
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

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(PREFIX)
        write(first_child.to_s)
      end

    end # NthRef

  end # Emitter
end # Unparser
