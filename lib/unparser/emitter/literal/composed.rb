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
            if parent_type == :send && parent.last_argument.eql?(node)
              dispatch_without_braces
            else
              dispatch_with_braces
            end
          end

        private

          # Perform usual dispatch with braces
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch_with_braces
            if children.empty?
              emit_braces
            else
              emit_children_and_braces
            end
          end

          # Perform dispatch without braces
          # (when hash is the last argument in a method call)
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch_without_braces
            if children.empty?
              # TODO: omit the hash altogether
              emit_braces
            else
              emit_children
            end
          end

          # Emit empty braces without spaces inside
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_braces
            parentheses(OPEN, CLOSE)
          end

          # Emit the hash with spaces
          # after `{` and before `}`
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_children_and_braces
            parentheses(OPEN, CLOSE) do
              ws
              emit_children
              ws
            end
          end

          # Emit hash pairs without braces
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_children
            delimited(children, DELIMITER)
          end
        end # Hash

        # Array literal emitter
        class Array < self
          OPEN      = '['.freeze
          CLOSE     = ']'.freeze
          DELIMITER = ', '.freeze

          handle :array

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

      end # Compound
    end # Literal
  end # Emitter
end # Unparser
