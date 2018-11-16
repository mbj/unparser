# frozen_string_literal: true

module Unparser
  class Emitter
    class Literal

      # Array literal emitter
      class Array < self
        OPEN  = '['.freeze
        CLOSE = ']'.freeze

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
            delimited(children)
          end
        end

      end # Array

    end # Literal
  end # Emitter
end # Unparser
