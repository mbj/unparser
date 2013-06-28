module Unparser
  class Emitter
    class Literal

      # Base class for primitive emitters
      class Primitive < self

        children :value

      private

        # Emitter for primitives based on Object#inspect
        class Inspect < self

          handle :int, :str, :float, :sym

        private

          # Dispatch value
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            buffer.append(value.inspect)
          end

        end # Inspect
      end # Primitive
    end # Literal
  end # Emitter
end # Unparser
