module Unparser
  class Emitter
    class Literal

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
