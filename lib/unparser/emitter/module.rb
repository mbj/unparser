module Unparser
  class Emitter
    # Emitter for module nodes
    class Module < self
      include LocalVariableRoot, Terminated

      handle :module

      children :name, :body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_MODULE, WS)
        visit(name)
        emit_body
        k_end
      end

    end # Module
  end # Emitter
end # Unparser
