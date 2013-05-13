module Unparser
  class Emitter
    class Literal
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
      end

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
          parentheses(OPEN, CLOSE) do
            delimited(children, DELIMITER)
          end
        end
      end # Hash

    end # Literal
  end # Emitter
end # Unparser
