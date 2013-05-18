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
        write(K_CLASS)
        ws
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
        write(' < ')
        visit(superclass)
      end

      # Emit body
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_body
        body = children[2]
        if body.type == :nil
          nl
          return
        end
        indented { visit(body) }
      end

    end # Class

    # Emitter for sclass nodes
    class SClass  < self

      handle :sclass

      O_SINGLETON = '<<'.freeze

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_CLASS)
        ws
        write(O_SINGLETON)
        ws
        visit(first_child)
        indented { visit(children[1]) }
        k_end
      end

    end # SClass
  end # Emitter
end # Unparser
