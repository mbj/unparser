module Unparser
  class Emitter
    class Literal
      # Abstract base class for literal range emitter
      class Range < self

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          parentheses do
            visit(begin_node)
            write(self.class::TOKEN)
            visit(end_node)
          end
        end

        # Return range begin node
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def begin_node
          children[0]
        end

        # Return range end node
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def end_node
          children[1]
        end

        # Inclusive range emitter
        class Inclusive < self
          TOKEN = '..'.freeze
          handle :irange
        end # Inclusive

        # Exclusive range emitter
        class Exclusive < self
          TOKEN = '...'.freeze
          handle :erange
        end # Exclusive

      end # Range
    end # Literal
  end # Emitter
end # Unparser
