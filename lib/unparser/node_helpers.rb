# encoding: UTF-8

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
    def n(type, children = [])
      Parser::AST::Node.new(type, children)
    end

  end # NodeHelpers
end # Unparser
