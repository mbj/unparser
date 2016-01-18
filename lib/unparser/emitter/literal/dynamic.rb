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
          visit_parentheses(dynamic_body, util::OPEN, util::CLOSE)
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

        end # String

        # Dynamic symbol literal emitter
        class Symbol < self

          OPEN = ':"'.freeze
          CLOSE = '"'.freeze

          handle :dsym

        end # Symbol
      end # Dynamic
    end # Literal
  end # Emitter
end # Unparser
