module Unparser
  class Emitter
    class Literal

      # Emitter for hash keyvalue pair
      class HashPair < self
        HASHROCKET = ' => '.freeze

        handle :pair

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          delimited(children, HASHROCKET)
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
          OPEN = '['.freeze
          CLOSE = ']'.freeze
          DELIMITER = ', '.freeze

          handle :array
        end # Array

      end # Compound
    end # Literal
  end # Emitter
end # Unparser
