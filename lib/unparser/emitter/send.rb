module Unparser
  class Emitter
    # Rest argument emitter
    class Restarg < self
      SPLAT = '*'.freeze

      handle :restarg

      def dispatch
        write(SPLAT)
        write(children.first.to_s)
      end

    end # Restarg

    # Arguments emitter
    class Arguments < self

      handle :args

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        delimited(children)
      end

    end # Arguments

    # Argument emitter
    class Argument < self

      handle :arg

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(children.first.to_s)
      end

    end # Argument



    # Block emitter
    class Block < self

      handle :block

      DO = ' do'.freeze
      END_NL = "end\n".freeze
      NL = "\n".freeze
      PIPE_OPEN = ' |'.freeze
      PIPE_CLOSE = '|'.freeze

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_send
        write(DO)
        emit_block_arguments
        emit_body
        write(END_NL)
      end

      # Emit send 
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_send
        visit(children.first)
      end

      # Emit arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_block_arguments
        arguments = children[1]
        parentheses(PIPE_OPEN, PIPE_CLOSE) do
          visit(arguments)
        end unless arguments.children.empty?
        write(NL)
      end

      # Emit body
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_body
        body = children[2]
        return if body.type == :nil
        visit(body)
        write(NL)
      end

    end
    # Block pass node emitter
    class BlockPass < self

      PASS = '&'.freeze

      handle :block_pass

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(PASS)
        visit(children.first)
      end

    end # BlockPass

    # Emitter for send
    class Send < self

      DOT = '.'.freeze

      handle :send

    private

      # Dispatch node
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_receiver
        emit_selector
        emit_arguments
      end

      # Return selector
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_selector
        write(children[1].to_s)
      end

      # Return arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_arguments
        arguments = children[2..-1]
        return if arguments.empty?
        parentheses do
          delimited(arguments)
        end
      end

      # Return receiver
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def emit_receiver
        receiver = children.first
        return unless receiver
        visit(receiver)
        write(DOT)
      end

    end # Send
  end # Emitter
end # Unparser
