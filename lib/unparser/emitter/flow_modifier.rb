# encoding: utf-8

module Unparser
  class Emitter
    # Emitter control flow modifiers
    class FlowModifier < self

      MAP = {
        return: K_RETURN,
        next:   K_NEXT,
        break:  K_BREAK,
      }

      handle(*MAP.keys)

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        conditional_parentheses((parent_type == :or || parent_type == :and) && children.any?) do
          write(MAP.fetch(node.type))
          emit_arguments
        end
      end

      # Emit break or return arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_arguments
        return if children.empty?
        ws
        head, *tail = children
        emit_argument(head)
        tail.each do |node|
          write(DEFAULT_DELIMITER)
          emit_argument(node)
        end
      end

      PARENS = [:if, :case, :begin].to_set.freeze

      # Emit argument
      #
      # @param [Parser::AST::Node] node
      #
      # @api private
      #
      def emit_argument(node)
        conditional_parentheses(PARENS.include?(node.type)) do
          visit(node)
        end
      end

    end # Return
  end # Emitter
end # Unparser
