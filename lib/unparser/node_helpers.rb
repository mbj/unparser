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
    def n(type, children = [])
      Parser::AST::Node.new(type, children)
    end

    def n?(type, node)
      node.type.equal?(type)
    end

    def n_flipflop?(node)
      n_iflipflop?(node) || n_eflipflop?(node)
    end

    def n_range?(node)
      n_irange?(node) || n_erange?(node)
    end

    %i[
      and
      arg
      args
      array
      array_pattern
      begin
      block
      cbase
      const
      dstr
      eflipflop
      empty_else
      erange
      ensure
      gvar
      hash
      hash_pattern
      if
      iflipflop
      in_pattern
      int
      irange
      kwarg
      kwargs
      kwsplat
      lambda
      lvar
      match_rest
      mlhs
      or
      pair
      rescue
      send
      shadowarg
      splat
      str
      sym
      xstr
    ].to_set.each do |type|
      name = "n_#{type}?"
      define_method(name) do |node|
        n?(type, node)
      end
      private(name)
    end

    def unwrap_single_begin(node)
      if n_begin?(node) && node.children.one?
        node.children.first
      else
        node
      end
    end
  end # NodeHelpers
end # Unparser
