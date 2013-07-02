module Unparser

  # Emitter base class
  class Emitter
    include Adamantium::Flat, AbstractType, Constants
    include Equalizer.new(:node, :buffer, :parent)

    # Registry for node emitters
    REGISTRY = {}

    DEFAULT_DELIMITER = ', '.freeze

    CURLY_BRACKETS = IceNine.deep_freeze(%w({ }))

    # Create name helpers
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.children(*names)
      names.each_with_index do |name, index|
        define_method(:remaining_children) do
          children[names.length..-1]
        end
        define_method(name) do
          children.at(index)
        end
        private name
      end
    end
    private_class_method :children

    # Register emitter for type
    #
    # @param [Symbol] type
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.handle(*types)
      types.each do |type|
        REGISTRY[type] = self
      end
    end
    private_class_method :handle

    # Emit node into buffer
    #
    # @return [self]
    #
    # @api private
    #
    def self.emit(*arguments)
      new(*arguments)
      self
    end

    # Initialize object
    #
    # @param [Parser::AST::Node] node
    # @param [Buffer] buffer
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(node, buffer, parent)
      @node, @buffer, @parent = node, buffer, parent
      dispatch
    end

    private_class_method :new

    # Visit node
    #
    # @param [Parser::AST::Node] node
    # @param [Buffer] buffer
    #
    # @return [Emitter]
    #
    # @api private
    #
    def self.visit(node, buffer, parent = Root)
      type = node.type
      emitter = REGISTRY.fetch(type) do
        raise ArgumentError, "No emitter for node: #{type.inspect}"
      end
      emitter.emit(node, buffer, parent)
      self
    end

    # Test if node needs begin
    #
    # @return [true]
    #   if if node needs begin
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    def needs_begin?
      false
    end

    # Return node
    #
    # @return [Parser::AST::Node] node
    #
    # @api private
    #
    attr_reader :node

  private

    # Return buffer
    #
    # @return [Buffer] buffer
    #
    # @api private
    #
    attr_reader :buffer
    protected :buffer

    # Return parent emitter
    #
    # @return [Parent]
    #
    # @api private
    #
    attr_reader :parent
    protected :parent

    # Emit contents of block within parentheses
    #
    # @return [undefined]
    #
    # @api private
    #
    def parentheses(open=M_PO, close=M_PC)
      write(open)
      yield
      write(close)
    end

    # Emit nodes source map
    #
    # @return [undefined]
    #
    # @api private
    #
    def emit_source_map
      SourceMap.emit(node, buffer)
    end

    # Dispatch helper
    #
    # @param [Parser::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def visit(node)
      self.class.visit(node, buffer, self)
    end

    # Emit delimited body
    #
    # @param [Enumerable<Parser::AST::Node>] nodes
    # @param [String] delimiter
    #
    # @return [undefined]
    #
    # @api private
    #
    def delimited(nodes, delimiter = DEFAULT_DELIMITER)
      max = nodes.length - 1
      nodes.each_with_index do |node, index|
        visit(node)
        write(delimiter) if index < max
      end
    end

    # Return children of node
    #
    # @return [Array<Parser::AST::Node>]
    #
    # @api private
    #
    def children
      node.children
    end

    # Write newline
    #
    # @return [undefined]
    #
    # @api private
    #
    def nl
      buffer.nl
    end

    # Write strings into buffer
    #
    # @return [undefined]
    #
    # @api private
    #
    def write(*strings)
      strings.each do |string|
        buffer.append(string)
      end
    end

    # Write end keyword
    #
    # @return [undefined]
    #
    # @api private
    #
    def k_end
      write(K_END)
    end

    # Return first child
    #
    # @return [Parser::AST::Node]
    #   if present
    #
    # @return [nil]
    #   otherwise
    #
    # @api private
    #
    def first_child
      children.first
    end

    # Write whitespace
    #
    # @return [undefined]
    #
    # @api private
    #
    def ws
      write(WS)
    end

    # Call emit contents of block indented
    #
    # @return [undefined]
    #
    # @api private
    #
    def indented
      buffer = self.buffer
      buffer.indent
      yield
      buffer.unindent
    end

    # Emit non nil body
    #
    # @param [Parser::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def emit_body
      unless body
        nl
        return
      end
      indented { visit(body) }
    end

    # Emitter that fully relies on parser source maps
    class SourceMap < self

      # Perform dispatch
      #
      # @param [Node] node
      # @param [Buffer] buffer
      #
      # @return [self]
      #
      # @api private
      #
      def self.emit(node, buffer)
        buffer.append(node.location.expression.source)
        self
      end

    end # SourceMap
  end # Emitter
end # Unparser
