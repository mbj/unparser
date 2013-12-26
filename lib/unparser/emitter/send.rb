module Unparser
  class Emitter
    # Emitter for send
    class Send < self

      handle :send

      INDEX_PARENS  = IceNine.deep_freeze(%w([ ]))
      NORMAL_PARENS = IceNine.deep_freeze(%w[( )])

      INDEX_REFERENCE = :'[]'
      INDEX_ASSIGN    = :'[]='
      ASSIGN_SUFFIX   = '='.freeze

      AMBIGOUS = [:irange, :erange].to_set.freeze

      children :receiver, :selector

      # Test for terminated expression
      #
      # @return [true]
      #   if send is terminated
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def terminated?
        [
          Unary,
          Index::Reference,
          Regular
        ].include?(effective_emitter)
      end

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        run(effective_emitter)
      end

      # Return effective emitter
      #
      # @return [Class:Emitter]
      #
      # @api private
      #
      def effective_emitter
        case selector
        when INDEX_REFERENCE
          Index::Reference
        when INDEX_ASSIGN
          Index::Assign
        else
          non_index_emitter
        end
      end
      memoize :effective_emitter

      # Return non index emitter
      #
      # @return [Class:Emitter]
      #
      # @api private
      #
      def non_index_emitter
        if binary_operator?
          Binary
        elsif unary_operator?
          Unary
        elsif attribute_assignment?
          AttributeAssignment
        else
          Regular
        end
      end

      # Return string selector
      #
      # @return [String]
      #
      # @api private
      #
      def string_selector
        selector.to_s
      end
      memoize :string_selector

      # Test for unary operator implemented as method
      #
      # @return [true]
      #   if node is a unary operator
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def unary_operator?
        UNARY_OPERATORS.include?(selector)
      end

      # Test for binary operator implemented as method
      #
      # @return [true]
      #   if node is a binary operator
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def binary_operator?
        BINARY_OPERATORS.include?(selector) && arguments.one? && arguments.first.type != :splat
      end

      # Emit selector
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_selector
        name = string_selector
        if mlhs?
          name = name[0..-2]
        end
        write(name)
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

      # Test for assignment
      #
      # FIXME: This also returns true for <= operator!
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
        string_selector[-1] == ASSIGN_SUFFIX
      end

      # Test for attribute assignment
      #
      # @return [true]
      #   if node represetns and attribute assignment
      #
      # @return [false]
      #
      # @api private
      #
      def attribute_assignment?
        !BINARY_OPERATORS.include?(selector) && !UNARY_OPERATORS.include?(selector) && assignment? && !mlhs?
      end

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

      # Emit arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_arguments
        run(Arguments, s(:arguments, arguments))
      end

    end # Send
  end # Emitter
end # Unparser
