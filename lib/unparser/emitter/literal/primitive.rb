module Unparser
  class Emitter
    class Literal

      # Base class for primitive emitters
      class Primitive < self

        children :value

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

        # Emitter for complex literals
        class Complex < self

          handle :complex

          RATIONAL_FORMAT = 'i'.freeze

          MAP =
            if 0.class.equal?(Integer)
              IceNine.deep_freeze(
                Float    => :float,
                Rational => :rational,
                Integer  => :int
              )
            else
              IceNine.deep_freeze(
                Float    => :float,
                Rational => :rational,
                Fixnum   => :int,
                Bignum   => :int
              )
            end

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
