module Unparser
  class Emitter
    class Literal < self
      class Range < self

      private

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

      class Array < self
        OPEN = '['.freeze
        CLOSE = ']'.freeze
        DELIMITER = ', '.freeze

        handle :array

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          parentheses(OPEN, CLOSE) do
            delimited(children, DELIMITER)
          end
        end
      end # Array

      class HashPair < self

        HASHROCKET = ' => '.freeze

        handle :pair

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          delimited(children, HASHROCKET)
        end
      end

      class Hash < self
        OPEN      = '{'.freeze
        CLOSE     = '}'.freeze
        DELIMITER = ', '.freeze

        handle :hash

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          parentheses(OPEN, CLOSE) do
            delimited(children, DELIMITER)
          end
        end
      end # Hash

    end # Literal
  end # Emitter
end # Unparser
