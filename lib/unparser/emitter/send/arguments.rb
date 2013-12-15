module Unparser
  class Emitter
    class Send

      # Emitter for arguments of send nodes
      class Arguments < Emitter

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          return if children.empty?

          parentheses do
            delimited(effective_arguments)
          end
        end

        # Return effective arguments
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def effective_arguments
          last = children.length - 1
          children.each_with_index.map do |argument, index|
            if last == index && argument.type == :hash
              argument.updated(:hash_body)
            else
              argument
            end
          end
        end

      end # Arguments
    end # Send
  end # Emitter
end # Unparser
