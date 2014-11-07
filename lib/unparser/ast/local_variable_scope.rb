# encoding: UTF-8

module Unparser
  module AST

    # Calculated local variable scope for a given node
    class LocalVariableScope
      include Enumerable, Adamantium, Concord.new(:node)

      # Initialize object
      #
      # @param [Parser::AST::Node] node
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(node)
        items = []
        LocalVariableScopeEnumerator.each(node) do |*scope|
          items << scope
        end
        @items = items
        super(node)
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

      # Test if local variables where first assigned in body and read by conditional
      #
      # @param [Parser::AST::Node] conditional
      # @param [Parser::AST::Node] body
      #
      # @api private
      #
      def first_assignment_in_body_and_used_in_condition?(body, condition)
        condition_reads = AST.local_variable_reads(condition)

        candidates = AST.local_variable_assignments(body).select do |node|
          name = node.children.first
          condition_reads.include?(name)
        end

        candidates.any? do |node|
          first_assignment?(node)
        end
      end

    private

      # Match node
      #
      # @param [Parser::AST::Node] node
      #   if block given
      #
      # @return [Boolean]
      #
      # @api private
      #
      def match(neddle)
        @items.each do |node, current, before|
          return yield(current, before) if node.equal?(neddle)
        end
        false
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
      def initialize
        @stack = [Set.new]
      end

      # Enumerate each node with its local variable scope
      #
      # @param [Parser::AST::Node] node
      #
      # @return [self]
      #
      # @api private
      #
      def self.each(node, &block)
        new.each(node, &block)
        self
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
      # @return [undefined]
      #
      # @api private
      #
      def visit(node, &block)
        before = current.dup
        enter(node)
        yield node, current.dup, before
        node.children.each do |child|
          visit(child, &block) if child.is_a?(Parser::AST::Node)
        end
        leave(node)
      end

      # Record local variable state
      #
      # @param [Parser::AST::Node]
      #
      # @return [undefined]
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
        pop if CLOSE_NODES.include?(node.type)
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
      #
      # @return [undefined]
      #
      # @api private
      #
      def pop
        @stack.pop
      end

    end # LocalVariableScopeEnumerator
  end # AST
end # Unparser
