module Unparser
  class Emitter
    # Emitter for module nodes
    class Module < self

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
        if parent_type != :send
          comment
          visit(name)
        end
      end

    end # Module
  end # Emitter
end # Unparser
