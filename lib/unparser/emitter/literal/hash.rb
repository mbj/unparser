module Unparser
  class Emitter
    class Literal

      # Abstract namespace class for hash pair emitters
      class HashPair < self

        # Pair emitter that emits hash-rocket separated key values
        class Rocket < self
          HASHROCKET = ' => '.freeze

          handle :pair_rocket

        private

          # Perform dispatch
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            delimited(children, HASHROCKET)
          end

        end # Rocket

        # Pair emitter that emits colon separated key values
        class Colon < self
          COLON      = ': '.freeze

          handle :pair_colon

          children :key, :value

        private

          # Perform dispatch
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            write(key.children.first.to_s, COLON)
            visit(value)
          end

        end # Colon

      end # HashPair

      # Emitter for hash bodies
      class HashBody < self

        DELIMITER = ', '.freeze
        BAREWORD = /\A[A-Za-z_][A-Za-z_0-9]*[?!]?\z/.freeze

        handle :hash_body

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          delimited(effective_body, DELIMITER)
        end

        # Return effective body
        #
        # @return [Enumerable<Parser::AST::Node>]
        #
        # @api private
        #
        def effective_body
          children.map do |pair|
            key, value = *pair
            if key.type == :sym && key.children.first.to_s =~ BAREWORD
              s(:pair_colon, pair.children)
            else
              s(:pair_rocket, pair.children)
            end
          end
        end

      end # HashBody

      # Emitter for Hash literals
      class Hash < self

        DELIMITER = ', '.freeze
        OPEN      = '{'.freeze
        CLOSE     = '}'.freeze

        handle :hash

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          if children.empty?
            write(OPEN, CLOSE)
          else
            emit_hash_body
          end
        end

        # Emit hash body
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_hash_body
          parentheses(OPEN, CLOSE) do
            write(WS)
            run(HashBody)
            write(WS)
          end
        end

      end # Hash
    end # Literal
  end # Emitter
end # Unparser
