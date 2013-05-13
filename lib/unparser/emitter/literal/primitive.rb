module Unparser
  class Emitter
    class Literal
      
      # Base class for primitive emitters
      class Primitive < self

      private

        def dispatch
          if node.source_map
            emit_source_map
          else
            dispatch_value
          end
        end

        abstract_method :disaptch_value

        def value
          node.children.first
        end

        # Emitter for primitives based on Object#inspect
        class Inspect < self

          handle :int, :str, :float, :sym

        private

          def dispatch_value
            buffer.append(value.inspect)
          end

        end
      end
    end
  end
end
