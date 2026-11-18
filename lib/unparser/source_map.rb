# frozen_string_literal: true

module Unparser
  # Maps AST nodes to their generated output ranges
  class SourceMap
    # Single mapping entry from an AST node to its range in generated output
    class Entry
      attr_reader :node, :generated_range

      def initialize(node:, generated_range:)
        @node            = node
        @generated_range = generated_range
        freeze
      end
    end # Entry

    attr_reader :entries

    def initialize
      @entries = []
    end

    # Record a node mapping
    #
    # @param node [Parser::AST::Node]
    # @param generated_range [Range]
    #
    # @return [self]
    def record(node:, generated_range:)
      @entries << Entry.new(node: node, generated_range: generated_range)
      self
    end

    # Find all entries for a specific node (by identity)
    #
    # @param node [Parser::AST::Node]
    #
    # @return [Array<Entry>]
    def for_node(node)
      @entries.select { |entry| entry.node.equal?(node) }
    end

    # Freeze the source map and its entries
    #
    # @return [self]
    def freeze
      @entries.freeze
      super
    end
  end # SourceMap
end # Unparser
