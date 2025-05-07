# frozen_string_literal: true

module Unparser
  module Writer
    class Send
      # Writer for unary sends
      class Unary < self
        MAP = {
          '-@': '-',
          '+@': '+'
        }.freeze

        private_constant(*constants(false))

        def dispatch # rubocop:disable Metrics/AbcSize
          name = selector
          first_child = children.fetch(0)

          if n_flipflop?(first_child) || n_and?(first_child) || n_or?(first_child)
            write 'not '
          else
            write(MAP.fetch(name, name).to_s)

            if n_int?(receiver) && selector.equal?(:+@)
              write('+')
            end
          end

          visit(receiver)
        end
      end # Unary
    end # Send
  end # Writer
end # Unparser
