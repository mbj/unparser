module Unparser

  # Emitter base class
  class Emitter
    include AbstractType, Equalizer.new(:node, :buffer)

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
      emitter = REGISTRY.fetch(type) do 
        raise ArgumentError, "No emitter for node: #{type.inspect}"
      end
      emitter.emit(node, buffer)
      self
    end

    abstract_singleton_method :emit

    # Emitter that fully relies on parser source maps
    class SourceMap < self

      handle :float
      handle :str
      handle :int
      handle :irange
      handle :erange
      handle :dstr
      handle :sym

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def self.emit(node, buffer)
        buffer.append(node.source_map.expression.to_source)
      end

    end # SourceMap
  end # Emitter
end # Unparser
