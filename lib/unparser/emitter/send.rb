# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for send
    # ignore :reek:TooManyMethods
    class Send < self

      handle :send

      ASSIGN_SUFFIX    = '='.freeze
      INDEX_ASSIGN     = :'[]='
      INDEX_REFERENCE  = :'[]'
      NON_ASSIGN_RANGE = (0..-2).freeze

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
        write(mlhs? ? non_assignment_selector : string_selector)
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
        if arguments.empty?
          write('()') if receiver.nil? && avoid_clash?
        else
          normal_arguments
        end
      end

      # Emit normal arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def normal_arguments
        parentheses do
          delimited_plain(effective_arguments)
        end
      end

      # The effective arguments
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def effective_arguments
        last = arguments.length - 1
        arguments.each_with_index.map do |argument, index|
          if last.equal?(index) && argument.type.equal?(:hash) && argument.children.any?
            argument.updated(:hash_body)
          else
            argument
          end
        end
      end

      # Test if clash with local variable or constant needs to be avoided
      #
      # @return [Boolean]
      #
      # @api private
      #
      def avoid_clash?
        local_variable_clash? || parses_as_constant?
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

      # The non assignment selector
      #
      # @return [String]
      #
      # @api private
      def non_assignment_selector
        string_selector[NON_ASSIGN_RANGE]
      end

      # Test if selector parses as constant
      #
      # @return [Boolean]
      #
      # @api private
      #
      def parses_as_constant?
        Unparser.parse(selector.to_s).type.equal?(:const)
      end
    end # Send
  end # Emitter
end # Unparser
