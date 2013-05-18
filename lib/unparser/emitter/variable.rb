module Unparser
  class Emitter

    # Emitter for cdecl nodes that will go away soon (parser-2.0.0)
    class Cdecl < self

      handle :cdecl

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        name, value = children[1, 2]
        write(name.to_s)
        if value
          write(' = ')
          visit(value)
        end
      end
    end

    # Emitter for cvdecl nodes that will go away soon (parser-2.0.0)
    class Cvdecl < self

      handle :cvdecl

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(first_child.to_s)
        value = children[1]
        if value
          write(' = ')
          visit(value)
        end
      end
    end

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
          write(CBase::BASE)
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
