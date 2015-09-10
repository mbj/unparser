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

      children :receiver, :selector

      def terminated?
        effective_emitter.terminated?
      end

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        effective_emitter.write_to_buffer
      end

      # Return effective emitter
      #
      # @return [Emitter]
      #
      # @api private
      #
      def effective_emitter
        effective_emitter_class.new(node, parent)
      end

      # Return effective emitter
      #
      # @return [Class:Emitter]
      #
      # @api private
      #
      def effective_emitter_class
        case selector
        when INDEX_REFERENCE
          Index::Reference
        when INDEX_ASSIGN
          Index::Assign
        else
          non_index_emitter
        end
      end

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

      # Test for unary operator implemented as method
      #
      # @return [Boolean]
      #
      # @api private
      #
      def unary_operator?
        UNARY_OPERATORS.include?(selector)
      end

      # Test for binary operator implemented as method
      #
      # @return [Boolean]
      #
      # @api private
      #
      def binary_operator?
        BINARY_OPERATORS.include?(selector) && arguments.one? && !arguments.first.type.equal?(:splat)
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
      # @return [Boolean]
      #
      # @api private
      #
      def mlhs?
        parent_type.equal?(:mlhs)
      end

      # Test for assignment
      #
      # FIXME: This also returns true for <= operator!
      #
      # @return [Boolean]
      #
      # @api private
      #
      def assignment?
        string_selector[-1].eql?(ASSIGN_SUFFIX)
      end

      # Test for attribute assignment
      #
      # @return [Boolean]
      #
      # @api private
      #
      def attribute_assignment?
        !BINARY_OPERATORS.include?(selector) && !UNARY_OPERATORS.include?(selector) && assignment? && !mlhs?
      end

      # Test for empty arguments
      #
      # @return [Boolean]
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
        if arguments.empty? && receiver.nil? && local_variable_clash?
          write('()')
        else
          run(Arguments, n(:arguments, arguments))
        end
      end

      # Test for local variable clash
      #
      # @return [Boolean]
      #
      # @api private
      #
      def local_variable_clash?
        local_variable_scope.local_variable_defined_for_node?(node, selector)
      end

    end # Send
  end # Emitter
end # Unparser
