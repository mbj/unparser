module Unparser
  class Emitter
    class Literal

      # Base class for primitive emitters
      class Primitive < self

        children :value

      private

        # Emitter for primitives based on Object#inspect
        class Inspect < self

          handle :float, :int

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

          class Symbol < self

            handle :sym

            # Dispatch value (without colon if representing a hash key)
            #
            # @return [undefined]
            #
            # @api private
            #
            def dispatch
              if parent.is_a?(HashPair) && parent.key.eql?(node) && safe_without_quotes?
                buffer.append(value.to_s)
              else
                super
              end
            end

            # Test if this symbol is safe to use without quoting
            #
            # @return [true]
            #   if the symbol is safe
            #
            # @return [false]
            #   otherwise
            #
            # @api private
            #
            def safe_without_quotes?
              value.inspect[1] != DBL_QUOTE
            end

          end

        end # Inspect

        # Literal emitter with macro regeneration base class
        class MacroSafe < self

        private

          # Perform dispatch
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            if source == macro
              write(macro)
              return
            end
            write(value.inspect)
          end

          # Return source, if present
          #
          # @return [String]
          #   if present
          #
          # @return [nil]
          #   otherwise
          #
          # @api private
          #
          def source
            location = node.location || return
            expression = location.expression || return
            expression.source
          end

          # Return marco
          #
          # @return [String]
          #
          # @api private
          #
          def macro
            self.class::MACRO
          end

          # String macro safe emitter
          class String < self
            MACRO = '__FILE__'.freeze
            handle :str
          end # String

          # Integer macro safe emitter
          class Integer < self
            MACRO = '__LINE__'.freeze
            handle :int
          end # Integer

        end # MacroSave
      end # Primitive
    end # Literal
  end # Emitter
end # Unparser
