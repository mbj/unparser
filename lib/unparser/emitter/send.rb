module Unparser
  class Emitter
    # Emitter for send
    class Send < self

      handle :send

    private

      # Dispatch node
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_receiver
        emit_selector
        emit_arguments
      end

      INDEX_SELECTOR = '[]'.freeze
      INDEX_ASSIGN   = '[]='.freeze

      ASSIGN_SUFFIX = '='.freeze

      INDEX_SELECTORS = [
        INDEX_SELECTOR,
        INDEX_ASSIGN
      ].freeze

      # Test for index operation
      #
      # @return [true]
      #   if send is an index operation
      #
      # @return [false]
      #
      # @api private
      #
      def index?
        INDEX_SELECTORS.include?(selector)
      end

      # Return selector
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_selector
        return if index?
        selector = self.selector
        if mlhs?
          selector = selector[0..-2]
        end
        write(selector)
      end

      # Test for mlhs
      #
      # @return [true]
      #   if node is within an mlhs
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def mlhs?
        assignment? && !arguments?
      end

      # Test for assigment
      #
      # @return [true]
      #   if node represents attribute / element assignment
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def assignment?
        selector[-1] == ASSIGN_SUFFIX
      end

      # Return selector
      #
      # @return [String]
      #
      # @api private
      #
      def selector
        children[1].to_s
      end
      memoize :selector
      protected :selector

      # Test for empty arguments
      #
      # @return [true]
      #   if arguments are empty
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def arguments?
        arguments.any?
      end

      # Return argument nodes
      #
      # @return [Array<Parser::AST::Node>]
      #
      # @api private
      #
      def arguments
        children[2..-1]
      end
      memoize :arguments

      INDEXED_PARENS = IceNine.deep_freeze(%w([ ]))
      NORMAL_PARENS = IceNine.deep_freeze(%w[( )])

      # Emit arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_arguments
        return unless arguments?
        parens = index? ? INDEXED_PARENS : NORMAL_PARENS
        parentheses(*parens) do
          delimited(arguments)
        end
      end

      # Return receiver
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def emit_receiver
        receiver = first_child
        return unless receiver
        visit(receiver)
        write(O_DOT) unless index?
      end

    end # Send
  end # Emitter
end # Unparser
