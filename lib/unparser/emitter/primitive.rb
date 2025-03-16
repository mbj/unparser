# frozen_string_literal: true

module Unparser
  class Emitter
    # Base class for primitive emitters
    class Primitive < self

      children :value

      class Symbol < self

        handle :sym

        private

        # mutant:disable
        def dispatch
          if inspect_breaks_parsing?
            write(":#{value.name.inspect}")
          else
            write(value.inspect)
          end
        end

        # mutant:disable
        def inspect_breaks_parsing?
          return false unless RUBY_VERSION < '3.2.'

          Unparser.parse(value.inspect)
          false
        rescue Parser::SyntaxError
          true
        end
      end # Symbol

      # Emitter for complex literals
      class Complex < self

        handle :complex

        RATIONAL_FORMAT = 'i'.freeze

        MAP =
          {
            ::Float    => :float,
            ::Rational => :rational,
            ::Integer  => :int
          }.freeze

      private

        def dispatch
          emit_imaginary
          write(RATIONAL_FORMAT)
        end

        def emit_imaginary
          visit(imaginary_node)
        end

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

        # rubocop:disable Lint/FloatComparison
        def dispatch
          integer = Integer(value)
          float   = value.to_f

          write_rational(integer.to_f.equal?(float) ? integer : float)
        end
        # rubocop:enable Lint/FloatComparison

        def write_rational(value)
          write(value.to_s, RATIONAL_FORMAT)
        end

      end # Rational

      # Emiter for numeric literals
      class Numeric < self

        handle :int

      private

        def dispatch
          write(value.inspect)
        end

      end # Numeric
    end # Primitive
  end # Emitter
end # Unparser
