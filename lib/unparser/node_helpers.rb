module Unparser
  module NodeHelpers

    # Helper for building nodes
    #
    # @param [Symbol]
    #
    # @return [Parser::AST::Node]
    #
    # @api private
    #
    def s(type, *children)
      Parser::AST::Node.new(type, children)
    end

    # Helper for building nodes
    #
    # @param [Symbol]
    #
    # @return [Parser::AST::Node]
    #
    # @api private
    #
    def n(type, children = [], properties = {})
      Parser::AST::Node.new(type, children, properties)
    end

    # Were these nodes separated by a line break in the original source?
    # (If in fact they were parsed from Ruby source)
    #
    # @param [Parser::AST::Node] first
    # @param [Parser::AST::Node] second
    #
    # @return [Boolean]
    #
    # @api private
    #
    def different_lines?(first, second)
      first.loc && second.loc && first.loc.last_line != second.loc.line
    end

    # Create a source map which covers all the source locations from all
    # the passed nodes.
    #
    # @param [Array<Parser::AST::Node>] nodes
    #
    # @return [Parser::Source::Map]
    #
    # @api private
    #
    def combined_source_map(nodes)
      range = nodes.map(&:loc).compact.map(&:expression).reduce(&:join)
      Parser::Source::Map.new(range)
    end

  end # NodeHelpers
end # Unparser
