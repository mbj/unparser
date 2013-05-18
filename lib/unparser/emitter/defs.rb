module Unparser
  class Emitter
    # Emitter for def node
    class Defs < self

      handle :defs

      K_DEF = 'def'.freeze
      O_DOT = '.'.freeze

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
        visit(first_child)
        write(O_DOT)
        emit_selector
        emit_arguments
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
        indented { visit(children[3]) }
      end

      # Emit selector
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_selector
        write(children[1].to_s)
      end

      # Emit arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_arguments
        arguments = children[2]
        return if arguments.children.empty?
        parentheses do
          visit(arguments)
        end
      end

    end # Def
  end # Emitter
end # Unparser
