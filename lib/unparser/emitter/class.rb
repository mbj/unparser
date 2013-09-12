module Unparser
  class Emitter
    # Emitter for class nodes
    class Class < self

      handle :class

      children :name, :superclass, :body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_CLASS, WS)
        visit(name)
        emit_superclass
        emit_body
        k_end
        unless parent_type == :send
          eol_comment { visit(name) }
        end
      end

      # Emit superclass
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_superclass
        return unless superclass
        write(WS, T_LT, WS)
        visit(superclass)
      end

    end # Class

    # Emitter for sclass nodes
    class SClass  < self

      handle :sclass

      children :object, :body

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_CLASS, WS, T_DLT, WS)
        visit(object)
        emit_body
        k_end
      end

    end # SClass
  end # Emitter
end # Unparser
