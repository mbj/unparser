module Unparser
  class Emitter
    class Literal
      class Dynamic < self

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          util = self.class
          parentheses(util::OPEN, util::CLOSE) do
            visit(dynamic_body)
          end
        end

        # Return dynamic body
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def dynamic_body
          Parser::AST::Node.new(:dynbody, children)
        end

        class String < self

          OPEN = CLOSE = '"'.freeze

          handle :dstr

        end # String

      end
    end # Literal
  end # Emitter
end # Unparser
