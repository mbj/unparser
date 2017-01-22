module Unparser
  class Emitter
    # Emitter control flow modifiers
    class FlowModifier < self

      MAP = {
        return: K_RETURN,
        next:   K_NEXT,
        break:  K_BREAK
      }.freeze

      handle(*MAP.keys)

      def terminated?
        children.empty?
      end

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(MAP.fetch(node.type))
        case children.length
        when 0 # rubocop:disable Lint/EmptyWhen
        when 1
          emit_single_argument
        else
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
        visit_plain(node)
      end

      # Emit single argument
      #
      # @api private
      #
      def emit_single_argument
        ws
        conditional_parentheses(PARENS.include?(first_child.type)) do
          visit_plain(first_child)
        end
      end

    end # Return
  end # Emitter
end # Unparser
