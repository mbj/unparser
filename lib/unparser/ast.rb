module Unparser
  # Namespace for AST processing tools
  module AST
    include Constants

    FIRST_CHILD                   = lambda { |node| node.children.first }
    TAUTOLOGY                     = lambda { |node| true }.freeze
    LOCAL_VARIABLE_CHILD_BOUNDARY = lambda { |node| !LOCAL_VARIABLE_CHILD_BOUNDARY_NODES.include?(node.type) }
    LOCAL_VARIABLE_RESET_BOUNDARY = lambda { |node| !LOCAL_VARIABLE_RESET_BOUNDARY_NODES.include?(node.type) }

    # Return local variable use
    #
    # @param [Parser::AST::Node] node
    #
    # @return [Set<Symbol>]
    #
    # @api private
    #
    def self.local_variable_use(node, condition = LOCAL_VARIABLE_CHILD_BOUNDARY)
      unless condition.call(node)
        node = node.updated(:root)
      end
      Enumerator.new(
        node,
        condition,
      ).type(:lvar).map(&FIRST_CHILD).to_set
    end

    # Return local variable scope
    #
    # @param [Parser::AST::Node] node
    #
    # @return [Set<Symbol>]
    #
    # @api private
    #
    def self.local_variable_scope(node, condition = LOCAL_VARIABLE_CHILD_BOUNDARY)
      unless condition.call(node)
        node = node.updated(:root)
      end
      Enumerator.new(
        node,
        condition,
      ).types(LOCAL_VARIABLE_ASSIGNMENT_NODES).map(&FIRST_CHILD).to_set
    end

    # Remove a node from AST by object identity!
    #
    # @param [Parser::AST::Node] root
    # @param [Parser::AST::Node] neddle
    #
    # @return [Parser::AST::Node]
    #   if neddle was removed in child or not present
    #
    # @return [nil]
    #   if neddle was equal to root
    #
    # @api private
    #
    def self.remove_node(root, neddle)
      return Parser::AST::Node.new(:empty, []) if root.equal?(neddle)

      mapped_children = root.children.map do |child|
        if child.kind_of?(Parser::AST::Node)
          remove_node(child, neddle)
        else
          child
        end
      end

      root.updated(nil, mapped_children)
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
        return unless node
        Walker.call(node, controller, &block)
      end

      # Return local variable intersection
      #
      # @param [Param::AST::Node] condition
      # @param [Param::AST::Node] body
      #
      # @return [Set<Symbol>]
      #
      # @api private
      #
      def self.local_variable_intersection(condition, body)
        reads = AST::Enumerator.local_variables_read(condition)
        writes = AST::Enumerator.local_variables_assigned(body)
        reads.intersection(writes)
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

      # Return the names of local variables assigned
      #
      # @param [Parser::AST::Node] node
      #
      # @return [Set<Symbol>]
      #
      # @api private
      #
      def self.local_variables_assigned(node)
        set(type(node, :lvasgn).map { |node| node.children.first })
      end

      # Return the names of local variables read
      #
      # @param [Parser::AST::Node] node
      #
      # @return [Set<Symbol>]
      #
      # @api private
      #
      def self.local_variables_read(node)
        set(type(node, :lvar).map { |node| node.children.first })
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

      TAUTOLOGY = lambda { |node| true }

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
