module Unparser
  class Emitter
    class Literal

      # Emitter for hash keyvalue pair
      class HashPair < self
        HASHROCKET = ' => '.freeze
        COLON      = ': '.freeze

        handle :pair

        children :key, :value

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          if key.type == :sym && key.children.first.inspect[1] != DBL_QUOTE
            emit_19_style_symbol
          else
            delimited(children, HASHROCKET)
          end
        end

        # Emit ruby 19 style symbol
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_19_style_symbol
          write(key.children.first.to_s, COLON)
          visit(value)
        end

      end # HashPair

      # Hash literal emitter
      class Hash < self

        OPEN      = '{'.freeze
        CLOSE     = '}'.freeze
        DELIMITER = ', '.freeze

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
            delimited(children, DELIMITER)
            write(WS)
          end
        end

      end # Hash

      # Array literal emitter
      class Array < self
        OPEN      = '['.freeze
        CLOSE     = ']'.freeze
        DELIMITER = ', '.freeze

        handle :array

      private

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

    end # Literal
  end # Emitter
end # Unparser
