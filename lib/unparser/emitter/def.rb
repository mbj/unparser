module Unparser
  class Emitter
    # Emitter for def node
    class Def < self

      handle :def

      K_DEF = 'def'.freeze

    private

      # Perform dispatch
      # 
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_DEF)
        ws
        write(first_child.to_s)
        emit_arguments
        indented { visit(children[2]) }
        k_end
      end

      # Emit arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_arguments
        arguments = children[1]
        return if arguments.children.empty?
        parentheses do
          visit(arguments)
        end
      end

    end # Def
  end # Emitter
end # Unparser
