# frozen_string_literal: true

module Unparser
  class Emitter

    # Base class for assignment emitters
    class Assignment < self
      BINARY_OPERATOR = %i[and or].freeze

      def symbol_name
        true
      end

    private

      def dispatch
        emit_left
        emit_right
      end

      def emit_right
        return unless right

        write(' = ')

        if BINARY_OPERATOR.include?(right.type)
          writer_with(Writer::Binary, node: right).emit_operator
        else
          right_emitter.write_to_buffer
        end
      end

      def right_emitter
        emitter(right)
      end
      memoize :right_emitter

      abstract_method :emit_left

      # Variable assignment emitter
      class Variable < self

        handle :lvasgn, :ivasgn, :cvasgn, :gvasgn

        children :name, :right

      private

        def emit_left
          write(name.to_s)
        end

      end # Variable

      # Constant assignment emitter
      class Constant < self

        handle :casgn

        children :base, :name, :right

      private

        def emit_left
          if base
            visit(base)
            write('::') unless n_cbase?(base)
          end
          write(name.to_s)
        end

      end # Constant
    end # Assignment
  end # Emitter
end # Unparser
