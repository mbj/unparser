module Unparser
  class Emitter
    class Literal

      # Emitter for regexp literals
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
            body.each do |child|
              write_body(child)
            end
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
            visit(s(:interpolated, [node]))
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
          location = node.location
          return DELIMITER unless location
          location.end.source[-1]
        end
        memoize :delimiter

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
