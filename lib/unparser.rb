require 'abstract_type'
require 'concord'
require 'parser/all'

# Library namespace
module Unparser

  class Buffer
    def initialize
      @content = ''
    end

    def append(string)
      @content << string
    end

    def content
      @content.dup.freeze
    end
  end

  class Emitter
    include AbstractType

    def initialize(node, buffer)
      @node, @buffer = node, buffer
      dispatch
    end

  private

    abstract_method :dispatch

    attr_reader :node
    private :node
    attr_reader :buffer
    private :buffer

    def emit(string)
      buffer.append(string)
    end

    def self.visit(node, buffer)
      type = node.type
      handler = REGISTRY.fetch(type) do 
        raise ArgumentError, "No emitter for node: #{type.inspect}"
      end

      handler.new(node, buffer)
    end

    REGISTRY = {}

    def self.handle(type)
      REGISTRY[type] = self
    end

    class Literal < self
      def value
        node.children[0]
      end

      class Inspect < self
        handle :str
        handle :int

      private

        def dispatch
          emit(value.inspect)
        end
      end

      class Dynamic < self
        class String < self
          handle :dstr

        private

          def dispatch
            p node
          end
        end
      end
    end
  end

  # Unparse ast into string
  #
  # @param [Parser::Node] node
  #
  # @return [String]
  #
  # @api private
  #
  def self.unparse(ast)
    buffer = Buffer.new
    Emitter.visit(ast, buffer)
    buffer.content
  end

end
