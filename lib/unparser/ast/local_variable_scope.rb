# frozen_string_literal: true

module Unparser
  class AST
    # Calculated local variable scope for a given node
    class LocalVariableScope
      include Adamantium, Anima.new(:static_local_variables, :node)

      # Initialize object
      #
      # @param [Parser::AST::Node] node
      #
      # @return [undefined]
      #
      # mutant:disable
      def initialize(*arguments)
        super

        items = []

        LocalVariableScopeEnumerator.each(
          node:  node,
          stack: static_local_variables.dup
        ) { |*scope| items << scope }

        @items = items
      end

      # Test if local variable was first at given assignment
      #
      # @param [Parser::AST::Node] node
      #
      # @return [Boolean]
      #
      # @api private
      #
      def first_assignment?(node)
        name = node.children.first
        match(node) do |current, before|
          current.include?(name) && !before.include?(name)
        end
      end

      # Test if local variable is defined for given node
      #
      # @param [Parser::AST::Node] node
      # @param [Symbol] name
      #
      # @return [Boolean]
      #
      # @api private
      #
      def local_variable_defined_for_node?(node, name)
        match(node) do |current|
          current.include?(name)
        end
      end

      # mutant:disable
      def local_variables_for_node(needle)
        @items.each do |node, current|
          return current if node.equal?(needle)
        end

        Set.new
      end

      # Test if local variables where first assigned in body and read by conditional
      #
      # @param [Parser::AST::Node] body
      # @param [Parser::AST::Node] condition
      #
      # @api private
      #
      def first_assignment_in?(left, right)
        condition_reads = AST.local_variable_reads(right)

        candidates = AST.local_variable_assignments(left).select do |node|
          condition_reads.include?(node.children.first)
        end

        candidates.any?(&public_method(:first_assignment?))
      end

    private

      def match(needle)
        @items.each do |node, current, before|
          return yield(current, before) if node.equal?(needle)
        end
      end

    end # LocalVariableScope

    # Local variable scope enumerator
    class LocalVariableScopeEnumerator
      include Enumerable

      # Initialize object
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(stack:)
        @stack = [stack]
      end

      # Enumerate each node with its local variable scope
      def self.each(node:, stack:, &block)
        new(stack: stack).each(node: node, &block)
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
      def each(node:, &block)
        visit(node, &block)
      end

    private

      def current
        @stack.last
      end

      def visit(node, &block)
        before = current.dup
        enter(node)
        yield node, current.dup, before
        node.children.each do |child|
          visit(child, &block) if child.instance_of?(Parser::AST::Node)
        end
        leave(node)
      end

      def enter(node)
        case node.type
        when *RESET_NODES
          push_reset
        when ASSIGN_NODES
          value = node.children.first and define(value)
        when *INHERIT_NODES
          push_inherit
        end
      end

      def leave(node)
        pop if CLOSE_NODES.include?(node.type)
      end

      def define(name)
        current << name
      end

      def push_reset
        @stack << Set.new
      end

      def push_inherit
        @stack << current.dup
      end

      def pop
        @stack.pop
      end

    end # LocalVariableScopeEnumerator
  end # AST
end # Unparser
