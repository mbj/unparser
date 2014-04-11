# encoding: UTF-8

module Unparser
  # Namespace for AST processing tools
  module AST

    FIRST_CHILD = ->(node) { node.children.first }.freeze
    TAUTOLOGY   = ->(node) { true }.freeze

    # Test if local variable was first at given assignment
    #
    # @param [Parser::AST::Node] root
    # @param [Parser::AST::Node] assignment
    #
    # @return [true]
    #   if local variable was firstly introduced in body
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    def self.first_assignment?(root, assignment)
      name = assignment.children.first
      AST::LocalVariableScope.each(root) do |node, current, before|
        if node.equal?(assignment) && current.include?(name) && !before.include?(name)
          return true
        end
      end

      false
    end

    # Test if local variable is defined for given node
    #
    # @param [Parser::AST::Node] root
    # @param [Parser::AST::Node] node
    # @param [Symbol] name
    #
    # @return [true]
    #   if local variable is defined
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    def self.local_variable_defined_for_node?(root, node, name)
      AST::LocalVariableScope.each(root) do |child, current, before|
        if child.equal?(node)
          return current.include?(name)
        end
      end

      false
    end

    # Test if local variables where first assigned in body and read by conditional
    #
    # @param [Parser::AST::Node] root
    # @param [Parser::AST::Node] conditional
    # @param [Parser::AST::Node] body
    #
    # @api private
    #
    def self.first_assignment_in_body_and_used_in_condition?(root, body, condition)
      condition_reads = local_variables_read_in_scope(condition)

      candidates = AST.local_variable_assignments_in_scope(body).select do |node|
        name = node.children.first
        condition_reads.include?(name)
      end

      candidates.any? do |node|
        first_assignment?(root, node)
      end
    end

    # Return local variables that get assigned in scope
    #
    # @param [Parser::AST::Node]
    #
    # @return [Set<Symbol>]
    #
    # @api private
    #
    def self.local_variable_assignments_in_scope(node)
      Enumerator.new(
        node,
        LocalVariableScope.method(:not_reset_scope?)
      ).types(LocalVariableScope::ASSIGN_NODES)
    end

    # Return local variables read
    #
    # @param [Parser::AST::Node] node
    #
    # @return [Set<Symbol>]
    #
    # @api private
    #
    def self.local_variables_read_in_scope(node)
      Enumerator.new(
        node,
        LocalVariableScope.method(:not_close_scope?)
      ).type(:lvar).map(&FIRST_CHILD).to_set
    end

    # AST enumerator
    class Enumerator
      include Adamantium::Flat, Concord.new(:node, :controller), Enumerable

      # Return new instance
      #
      # @param [Parser::AST::Node] node
      # @param [#call(node)] controller
      #
      # @return [Enumerator]
      #
      # @api private
      #
      def self.new(node, controller = TAUTOLOGY)
        super
      end

      # Return each node
      #
      # @return [Enumerator<Parser::AST::Node>]
      #   if no block given
      #
      # @return [self]
      #   otherwise
      #
      # @api private
      #
      def each(&block)
        return to_enum unless block_given?
        Walker.call(node, controller, &block)
      end

      # Return nodes selected by types
      #
      # @param [Enumerable<Symbol>] types
      #
      # @return [Enumerable<Parser::AST::Node>]
      #
      # @api private
      #
      def types(types)
        select { |node| types.include?(node.type) }
      end

      # Return nodes selected by type
      #
      # @param [Symbol] type
      #
      # @return [Enumerable<Parser::AST::Node>]
      #
      # @api private
      #
      def type(type)
        select { |node| node.type == type }
      end

      # Return frozne set of objects
      #
      # @param [Enumerable] enumerable
      #
      # @return [Set]
      #
      # @api private
      #
      def self.set(enumerable)
        enumerable.to_set.freeze
      end
      private_class_method :set

      # Return nodes of type
      #
      # @param [Parser::AST::Node] node
      # @param [Symbol] type
      #
      # @return [Enumerable<Parser::AST::Node]
      #
      # @api private
      #
      def self.type(node, type)
        new(node).type(type)
      end
      private_class_method :type

    end # Enumerator

    # Controlled AST walker walking the AST in deeth first search with pre order
    class Walker
      include Concord.new(:block, :controller)

      # Call ast walker
      #
      # @param [Parser::AST::Node] node
      #
      # @return [self]
      #
      # @api private
      #
      def self.call(node, controller = TAUTOLOGY, &block)
        new(block, controller).call(node)
        self
      end

      # Call walker with node
      #
      # @param [Parser::AST::Node] node
      #
      # @return [self]
      #
      # @api private
      #
      def call(node)
        return unless controller.call(node)
        block.call(node)
        node.children.each do |child|
          if child.kind_of?(Parser::AST::Node)
            call(child)
          end
        end
        self
      end

    end # Walker
  end # AST
end # Unparser
