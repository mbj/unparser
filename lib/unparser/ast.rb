# frozen_string_literal: true

module Unparser
  # Namespace for AST processing tools
  class AST
    include Anima.new(:comments, :explicit_encoding, :node, :static_local_variables)

    FIRST_CHILD = ->(node) { node.children.first }.freeze

    RESET_NODES   = %i[module class sclass def defs].freeze
    INHERIT_NODES = [:block].freeze
    CLOSE_NODES   = (RESET_NODES + INHERIT_NODES).freeze

    # Nodes that assign a local variable
    ASSIGN_NODES =
      %i[
        arg
        kwarg
        kwoptarg
        kwrestarg
        lvasgn
        optarg
        restarg
      ].to_set.freeze

    # mutant:disable
    def self.from_node(node:)
      new(
        comments:               EMPTY_ARRAY,
        explicit_encoding:      nil,
        node:,
        static_local_variables: Set.new
      )
    end

    # Test for local variable inherited scope reset
    #
    # @param [Parser::AST::Node] node
    #
    # @return [Boolean]
    #
    # @api private
    #
    def self.not_close_scope?(node)
      !CLOSE_NODES.include?(node.type)
    end

    # Test for local variable scope reset
    #
    # @param [Parser::AST::Node] node
    #
    # @return [Boolean]
    #
    # @api private
    #
    def self.not_reset_scope?(node)
      !RESET_NODES.include?(node.type)
    end

    # Return local variables that get assigned in scope
    #
    # @param [Parser::AST::Node] node
    #
    # @return [Set<Symbol>]
    #
    # @api private
    #
    def self.local_variable_assignments(node)
      Enumerator.new(
        node,
        method(:not_reset_scope?)
      ).types(ASSIGN_NODES)
    end

    # Return local variables read
    #
    # @param [Parser::AST::Node] node
    #
    # @return [Set<Symbol>]
    #
    # @api private
    #
    # mutant:disable
    def self.local_variable_reads(node)
      Enumerator.new(
        node,
        method(:not_close_scope?)
      ).type(:lvar).map(&FIRST_CHILD).to_set
    end

    # AST enumerator
    class Enumerator
      include Adamantium, Concord.new(:node, :controller), Enumerable

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
      def each(&)
        Walker.call(node, controller, &)
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
        select { |node| node.type.equal?(type) }
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
      # @api private
      #
      def self.call(node, controller, &block)
        new(block, controller).call(node)
      end

      # Call walker with node
      #
      # @param [Parser::AST::Node] node
      #
      # @return [undefined]
      #
      # @api private
      #
      def call(node)
        return unless controller.call(node)

        block.call(node)
        node.children.each do |child|
          break unless child.instance_of?(Parser::AST::Node)

          call(child)
        end
      end

    end # Walker
  end # AST
end # Unparser
