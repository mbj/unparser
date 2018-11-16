# frozen_string_literal: true

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
    # ignore :reek:UncommunicativeMethodName
    # ignore :reek:UtilityFunction
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
    # ignore :reek:UncommunicativeMethodName
    # ignore :reek:UtilityFunction
    def n(type, children = [])
      Parser::AST::Node.new(type, children)
    end

  end # NodeHelpers
end # Unparser
