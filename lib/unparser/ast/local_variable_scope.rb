module Unparser
  module AST
    # Local variable scope enumerator
    class LocalVariableScope
      include Enumerable

      RESET_NODES   = [:module, :class, :sclass, :def, :defs].freeze
      INHERIT_NODES = [:block].freeze
      CLOSE_NODES   = (RESET_NODES + INHERIT_NODES).freeze

      # Nodes that assign a local variable
      #
      # FIXME: Kwargs are missing.
      #
      ASSIGN_NODES = [:lvasgn, :arg, :optarg].freeze

      # Initialize object
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize
        @stack = [Set.new]
      end

      def self.each(node, &block)
        new.each(node, &block)
      end

      # Test for local variable scope reset
      #
      # @param [Parser::AST::Node] node
      #
      # @return [true]
      #   if local variable scope must NOT be reset
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def self.not_reset_scope?(node)
        !RESET_NODES.include?(node.type)
      end

      # Enumerate local variable scope scope
      #
      # @return [self]
      #   if block given
      #
      # @return [Enumerator<Array<Symbol>>>]
      #   otherwise
      #
      # @api private
      #
      def each(node, &block)
        return to_enum(__method__, node) unless block_given?
        visit(node, &block)
      end

    private

      # Return current set of local variables
      #
      # @return [Set<Symbol>]
      #
      # @api private
      #
      def current
        @stack.last
      end

      # Visit node and record local variable state
      #
      # @param [Parser::AST::Node]
      #
      # @api private
      #
      def visit(node, &block)
        before = current.dup
        enter(node)
        yield node, current, before
        node.children.each do |child|
          if child.kind_of?(Parser::AST::Node)
            visit(child, &block)
          end
        end
        leave(node)
      end

      # Record local variable state
      #
      # @param [Parser::AST::Node]
      #
      # @api private
      #
      def enter(node)
        case node.type
        when *RESET_NODES
          push_reset
        when *ASSIGN_NODES
          define(node.children.first)
        when *INHERIT_NODES
          push_inherit
        end
      end

      # Pop from local variable state
      #
      # @param [Parser::AST::Node] node
      #
      # @return [undefined]
      #
      # @api private
      #
      def leave(node)
        if CLOSE_NODES.include?(node.type)
          pop
        end
      end

      # Define a local variable on current stack
      #
      # @param [Symbol] name
      #
      # @return [undefined]
      #
      # @api private
      #
      def define(name)
        current << name
      end

      # Push reset scope on stack
      #
      # @return [undefined]
      #
      # @api private
      #
      def push_reset
        @stack << Set.new
      end

      # Push inherited lvar scope on stack
      #
      # @return [undefined]
      #
      # @api private
      #
      def push_inherit
        @stack << current.dup
      end

      # Pop lvar scope from stack
      def pop
        @stack.pop
      end

    end # LocalVariableScope
  end # AST
end # Unparser
