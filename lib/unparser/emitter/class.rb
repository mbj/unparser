module Unparser
  class Emitter
    # Emitter for class nodes
    class Class < self

      handle :class

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_CLASS, WS)
        visit(first_child)
        emit_superclass
        emit_body
        k_end
      end

      # Emit superclass
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_superclass
        superclass = children[1]
        return unless superclass
        write(WS, O_LT, WS)
        visit(superclass)
      end

      # Emit body
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_body
        emit_non_nil_body(children[2])
      end

    end # Class

    # Emitter for sclass nodes
    class SClass  < self

      handle :sclass

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_CLASS, WS, O_DLT, WS) 
        visit(first_child)
        emit_non_nil_body(children[1])
        k_end
      end

    end # SClass
  end # Emitter
end # Unparser
