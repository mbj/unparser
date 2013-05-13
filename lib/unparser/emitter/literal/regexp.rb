module Unparser
  class Emitter
    class Literal
      class Regexp < self
        OPEN = CLOSE = '/'.freeze

        handle :regexp

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          parentheses(OPEN, CLOSE) do
            visit(dynamic_body)
          end
          visit(children.last)
        end

        # Return dynamic body
        #
        # @return [undefined]
        #
        # @api private
        #
        def dynamic_body
          Parser::AST::Node.new(:dynbody, children[0..-2])
        end

      end # Regexp

      class Regopt < self

        handle :regopt

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          write(children.map(&:to_s).join)
        end
      end

    end # Literal
  end # Emitter
end # Unparser
