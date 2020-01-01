# frozen_string_literal: true

module Unparser
  module NodeHelpers

    # Helper for building nodes
    #
    # @param [Symbol] type
    # @param [Parser::AST::Node] children
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
    # @param [Symbol] type
    #
    # @return [Parser::AST::Node]
    # @param [Array] children
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
