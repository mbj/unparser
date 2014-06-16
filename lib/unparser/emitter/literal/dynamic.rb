# encoding: utf-8

module Unparser
  class Emitter
    class Literal

      # Base class for dynamic literal emitters
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
          if interpolation?
            visit_parentheses(dynamic_body, util::OPEN, util::CLOSE)
          else
            emit_non_interpolated
          end
        end

        # Test for interpolation
        #
        # @return [Boolean]
        #
        # @api private
        #
        def interpolation?
          children.any? { |child| !child.type.equal?(:str) }
        end

        # Return dynamic body
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def dynamic_body
          Parser::AST::Node.new(:dyn_str_body, children)
        end

        # Dynamic string literal emitter
        class String < self

          OPEN = CLOSE = '"'.freeze
          handle :dstr

        private

          # Emit non interpolated form
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_non_interpolated
            delimited(children, WS)
          end

        end # String

        # Dynamic symbol literal emitter
        class Symbol < self

          OPEN = ':"'.freeze
          CLOSE = '"'.freeze

          handle :dsym

        private

          # Emit non interpolated form
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_non_interpolated
            visit_parentheses(dynamic_body, OPEN, CLOSE)
          end

        end # Symbol

      end
    end # Literal
  end # Emitter
end # Unparser
