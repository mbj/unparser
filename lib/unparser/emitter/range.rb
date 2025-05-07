# frozen_string_literal: true

module Unparser
  class Emitter
    # Range emitters
    class Range < self
      TOKENS = {
        irange: '..',
        erange: '...'
      }.freeze

      SYMBOLS = {
        erange: :tDOT3,
        irange: :tDOT2
      }.freeze

      def symbol_name
        true
      end

      handle(*TOKENS.keys)

      children :begin_node, :end_node

    private

      def dispatch
        visit_begin_node(begin_node)
        write(TOKENS.fetch(node.type))
        visit_end_node(end_node)
      end

      def visit_begin_node(node)
        return unless node

        if n_array?(begin_node)
          writer_with(Writer::Array, node: begin_node).emit_compact
        else
          visit(begin_node)
        end
      end

      def visit_end_node(node)
        return unless node

        write(' ') if n_range?(node)
        if n_array?(node)
          writer_with(Writer::Array, node: node).emit_compact
        else
          visit(node)
        end
      end

    end # Range
  end # Emitter
end # Unparser
