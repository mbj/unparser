module Unparser
  class Emitter
    class Literal
      class Regexp < self
        DELIMITER = '/'.freeze

        handle :regexp

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          parentheses(DELIMITER, DELIMITER) do
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
          Parser::AST::Node.new(:dyn_regexp_body, dynamic_body_children)
        end

        # Return dynamic body children
        #
        # @return [Enumerable<Parser::AST::Node>]
        #
        # @api private
        #
        def dynamic_body_children
          children[0..-2].map do |child|
            escape(child)
          end
        end

        # Return escaped child
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def escape(child)
          return child unless child.type == :str
          source = child.children.first
          Parser::AST::Node.new(:str, [Unparser.transquote(source, delimiter, DELIMITER)])
        end

        # Return closing delimiter 
        #
        # @return [String]
        #
        # @api private
        #
        def delimiter
          source_map = node.source_map
          return DELIMITER unless source_map
          source_map.expression.to_source[-1]
        end
        memoize :delimiter

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
