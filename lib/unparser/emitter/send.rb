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

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        case selector
        when INDEX_REFERENCE
          run(Index::Reference)
        when INDEX_ASSIGN
          run(Index::Assign)
        else
          non_index_dispatch
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

      # Emit unambiguous receiver
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_unambiguous_receiver
        receiver = effective_receiver
        if AMBIGOUS.include?(receiver.type) or binary_receiver?
          parentheses { visit(receiver) }
          return
        end

        visit(receiver)
      end

      # Return effective receiver
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def effective_receiver
        receiver = first_child
        children = receiver.children
        if receiver.type == :begin && children.length == 1
          receiver = children.first
        end
        receiver
      end

      # Test for binary receiver
      #
      # @return [true]
      #   if receiver is a binary operation implemented by a method
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def binary_receiver?
        receiver = effective_receiver
        case receiver.type
        when :or_asgn, :and_asgn
          true
        when :send
          BINARY_OPERATORS.include?(receiver.children[1])
        else
          false
        end
      end

      # Delegate to emitter
      #
      # @param [Class:Emitter] emitter
      #
      # @return [undefined]
      #
      # @api private
      #
      def run(emitter)
        emitter.emit(node, buffer, self)
      end

      # Perform non index dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def non_index_dispatch
        if binary?
          run(Binary)
          return
        elsif unary?
          run(Unary)
          return
        end
        regular_dispatch
      end

      # Perform regular dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def regular_dispatch
        emit_receiver
        emit_selector
        emit_arguments
      end

      # Return receiver
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def emit_receiver
        return unless first_child
        emit_unambiguous_receiver
        write(T_DOT)
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
        BINARY_OPERATORS.include?(selector)
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
