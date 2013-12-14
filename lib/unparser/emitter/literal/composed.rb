module Unparser
  class Emitter
    class Literal

      # Emitter for hash keyvalue pair
      class HashPair < self
        HASHROCKET = ' => '.freeze
        COLON      = ': '.freeze

        handle :pair

        # Return the AST node representing the key
        # 
        # @return [Parser::AST::Node]
        #   if present
        #
        # @return [nil]
        #   otherwise
        # 
        # @api private
        # 
        alias_method :key, :first_child
        public :key

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          if key.type == :sym && emitter(key).safe_without_quotes?
            delimited(children, COLON)
          else
            delimited(children, HASHROCKET)
          end
        end

      end # HashPair

      # Base class for compound literal emitters
      class Compound < self

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
            delimited(children, util::DELIMITER)
          end
        end

        # Hash literal emitter
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
            if children.empty?
              super
            else
              emit_with_spaces
            end
          end

        private

          # Emit the hash with spaces
          # after `{` and before `}`
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_with_spaces
            parentheses(OPEN, CLOSE) do
              ws
              delimited(children, DELIMITER)
              ws
            end
          end
        end # Hash

        # Array literal emitter
        class Array < self
          OPEN      = '['.freeze
          CLOSE     = ']'.freeze
          DELIMITER = ', '.freeze

          handle :array
        end # Array

      end # Compound
    end # Literal
  end # Emitter
end # Unparser
