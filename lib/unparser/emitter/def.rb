module Unparser
  class Emitter
    # Emitter for def node
    class Def < self

    private

      # Emit name
      #
      # @return [undefined]
      #
      # @api private
      # 
      abstract_method :emit_name
      private :emit_name

      # Return body node
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      # 
      abstract_method :body
      private :body

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_DEF, WS)
        emit_name
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
        indented { visit(body) }
      end

      # Emit arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_arguments
        arguments = argument_node
        return if arguments.children.empty?
        parentheses do
          visit(arguments)
        end
      end

      # Instance def emitter
      class Instance < self

        handle :def

      private

        # Emit name
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_name
          write(first_child.to_s)
        end

        # Return body node
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def body
          children[2]
        end

        # Emit argument node
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def argument_node
          children[1]
        end
      end # Instance

      # Emitter for defines on singleton
      class Singleton < self

        handle :defs

      private

        # Return mame
        #
        # @return [String]
        #
        # @api private
        #
        def emit_name
          visit(first_child)
          write(O_DOT, children[1].to_s)
        end

        # Return argument node
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def argument_node
          children[2]
        end

        # Return body
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def body
          children[3]
        end

      end # Singleton
    end # Def
  end # Emitter
end # Unparser
