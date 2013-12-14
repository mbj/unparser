module Unparser
  class Emitter
    class Send
      # Emitter for "regular" receiver.selector(arguments...) case
      class Regular < self

      private

        # Perform regular dispatch
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

        # Return receiver
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def emit_receiver
          return unless first_child
          visit_terminated(receiver)
          write(T_DOT)
        end

        # Emit arguments
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_arguments
          return if arguments.empty?
          parentheses do
            delimited(self.class.prepare_arguments(arguments))
          end
        end

        # Prepare arguments, replacing the last one with it's children
        # if it's a hash (thus replacing the hash with it's pairs)
        #
        # @return [Array<Parser::AST::Node>]
        #
        # @api private
        #
        def self.prepare_arguments(arguments)
          args = arguments.dup
          if args.last.type == :hash
            last_arg = args.pop
            args.push(*last_arg.children)
          end

          args
        end

      end # Regular
    end # Send
  end # Emitter
end # Unparser
