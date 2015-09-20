module Unparser
  class Emitter
    class Literal

      # Base class for primitive emitters
      class Primitive < self

        children :value

        # Emitter for string literals
        class String < self
          handle :str

        private

          # Dispatch value
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            if value.include? "'"
              # Write %()-style strings for strings with both double and single
              # quotes
              if value.include? '"'
                write("%(#{value})")
              else
                # Write double-quoted strings for strings with single but not
                # double quotes
                write(value.inspect)
              end
            else
              # Write single-quoted strings for strings with just double quotes
              # or no quotes at all
              write("'#{value}'")
            end
          end
        end

        # Emitter for primitives based on Object#inspect
        class Inspect < self

          handle :sym

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

        # Emitter for complex literals
        class Complex < self

          handle :complex

          RATIONAL_FORMAT = 'i'.freeze

          MAP = IceNine.deep_freeze(
            Float    => :float,
            Rational => :rational,
            Fixnum   => :int,
            Bignum   => :int
          )

        private

          # Dispatch value
          #
          # @return [undefined]
          #
          def dispatch
            emit_imaginary
            write(RATIONAL_FORMAT)
          end

          # Emit imaginary component
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_imaginary
            visit(imaginary_node)
          end

          # Return imaginary node
          #
          # @return [Parser::AST::Node]
          #
          # @api private
          #
          def imaginary_node
            imaginary = value.imaginary
            s(MAP.fetch(imaginary.class), imaginary)
          end

        end # Rational

        # Emitter for rational literals
        class Rational < self

          handle :rational

          RATIONAL_FORMAT = 'r'.freeze

        private

          # Dispatch value
          #
          # @return [undefined]
          #
          def dispatch
            integer = value.to_i
            float   = value.to_f

            write_rational(integer.to_f.eql?(float) ? integer : float)
          end

          # Write rational format
          #
          # @param [#to_s]
          #
          # @return [undefined]
          #
          # @api private
          #
          def write_rational(value)
            write(value.to_s, RATIONAL_FORMAT)
          end

        end # Rational

        # Emiter for numeric literals
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
            conditional_parentheses(parent.is_a?(Emitter::Send) && value < 0) do
              write(value.inspect)
            end
          end

        end # Numeric
      end # Primitive
    end # Literal
  end # Emitter
end # Unparser
