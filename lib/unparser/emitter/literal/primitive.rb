# encoding: utf-8

module Unparser
  class Emitter
    class Literal

      # Base class for primitive emitters
      class Primitive < self

        children :value

      private

        # Emitter for primitives based on Object#inspect
        class Inspect < self

          handle :sym, :str

        private

          # Dispatch value
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            write(value.inspect)
          end

        end # Inspect

        class Numeric < self

          handle :int, :float

        private

          # Dispatch value
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            conditional_parentheses(parent.kind_of?(Emitter::Send) && value < 0) do
              write(value.inspect)
            end
          end

        end # Numeric
      end # Primitive
    end # Literal
  end # Emitter
end # Unparser
