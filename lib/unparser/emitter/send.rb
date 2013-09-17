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
        if binary?
          Binary
        elsif unary?
          Unary
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

      # Delegate to emitter
      #
      # @param [Class:Emitter] emitter
      #
      # @return [undefined]
      #
      # @api private
      #
      def run(emitter)
        emitter.new(node, self).write_to_buffer
      end

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
      def unary?
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
      def binary?
        BINARY_OPERATORS.include?(selector) && arguments.length == 1 && arguments.first.type != :splat
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

      # Emit arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_arguments
        args = arguments
        return if args.empty?
        parentheses do
          delimited(args)
        end
      end

    end # Send
  end # Emitter
end # Unparser
