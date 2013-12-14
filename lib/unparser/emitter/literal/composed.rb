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
