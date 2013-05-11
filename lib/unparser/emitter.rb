module Unparser

  # Emitter base class
  class Emitter
    include AbstractType

    # Registry of node emitters
    REGISTRY = {}

    # Register emitter for type
    #
    # @param [Symbol] type
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.handle(type)
      REGISTRY[type] = self
    end
    private_class_method :handle

    # Visit node
    #
    # @param [Parser::AST::Node] node
    # @param [Buffer] buffer
    #
    # @return [Emitter]
    #
    # @api private
    #
    def self.visit(node, buffer)
      type = node.type
      klass = REGISTRY.fetch(type) do 
        raise ArgumentError, "No emitter for node: #{type.inspect}"
      end

      klass.new(node, buffer)
    end

    # Initialize emitter
    #
    # @param [Parser::AST::Node] node
    # @param [Buffer] buffer
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(node, buffer)
      @node, @buffer = node, buffer
      dispatch
    end

  private

    abstract_method :dispatch

    # Return node
    #
    # @return [Parser::AST::Node]
    #
    # @api private
    #
    attr_reader :node
    private :node

    # Return buffer
    #
    # @return [Buffer]
    #
    # @api private
    #
    attr_reader :buffer
    private :buffer

    # Emit string
    #
    # @param [String] string
    #
    # @return [undefined]
    #
    # @api private
    #
    def emit(string)
      buffer.append(string)
    end

    # Visit node
    #
    # @param [Parser::AST::Node] node
    #
    # @return [Emitter]
    #
    # @api private
    #
    def visit(node)
      self.class.visit(node, buffer)
    end

    # Emitter that can fully rely in parsers source maps
    class SourceMappedNode < self

      handle :str
      handle :int
      handle :irange
      handle :erange
      handle :dstr

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit(node.source_map.expression.to_source)
      end

    end # SourceMappedNode
  end # Emitter
end # Unparser
