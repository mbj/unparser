module Unparser
  class Emitter
    class Literal

      # Abstract namespace class for hash pair emitters
      class HashPair < self

        children :key, :value

      private

        # Emit value
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_value
          value_type = value.type
          conditional_parentheses(value_type.equal?(:if)) do
            visit(value)
          end
        end

        # Pair emitter that emits hash-rocket separated key values
        class Rocket < self
          HASHROCKET = ' => '.freeze

          handle :pair_rocket, :pair

        private

          # Perform dispatch
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            visit(key)
            write(HASHROCKET)
            emit_value
          end

        end # Rocket

        # Pair emitter that emits colon separated key values
        class Colon < self
          COLON = ': '.freeze

          handle :pair_colon

        private

          # Perform dispatch
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            write(key.children.first.to_s, COLON)
            emit_value
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
            if pair.type.equal?(:kwsplat)
              pair
            else
              key, _value = *pair
              if key.type.equal?(:sym) && key.children.first.to_s =~ BAREWORD
                n(:pair_colon, pair.children)
              else
                n(:pair_rocket, pair.children)
              end
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
