module Unparser
  class Emitter
    # Emitter for module nodes
    class Module < self

      handle :module

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_MODULE, WS)
        visit(first_child)
        emit_body
        k_end
      end

      # Emit body
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_body
        emit_non_nil_body(children[1])
      end

    end # Module
  end # Emitter
end # Unparser
