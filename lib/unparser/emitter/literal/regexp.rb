module Unparser
  class Emitter
    class Literal

      # Emitter for regexp literals
      class Regexp < self
        DELIMITER = '/'.freeze
        ESCAPED_DELIMITER = '\/'.freeze

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
            body.each(&method(:write_body))
          end
          visit(children.last)
        end

        # Return non regopt children
        #
        # @return [Array<Parser::AST::Node>]
        #
        # @api private
        #
        def body
          children[0..-2]
        end

        # Write specific body component
        #
        # @param [Parser::AST::Node] node
        #
        # @return [undefined]
        #
        # @api private
        #
        def write_body(node)
          case node.type
          when :str
            buffer.append_without_prefix(escape(node).children.first)
          else
            visit(s(:interpolated, node))
          end
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
        # @param [Parser::AST::Node] child
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def escape(child)
          source = child.children.first
          s(:str, source.gsub(DELIMITER, ESCAPED_DELIMITER))
        end

      end # Regexp

      # Emitter for regexp options
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

      end # Regopt

    end # Literal
  end # Emitter
end # Unparser
