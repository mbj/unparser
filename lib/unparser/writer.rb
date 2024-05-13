# frozen_string_literal: true

module Unparser
  module Writer
    include Generation, NodeHelpers

    def self.included(descendant)
      descendant.class_eval do
        include Adamantium, Anima.new(:buffer, :comments, :node, :local_variable_scope)

        extend DSL
      end
    end

  private

    def emitter(node)
      Emitter.emitter(
        buffer:               buffer,
        comments:             comments,
        node:                 node,
        local_variable_scope: local_variable_scope
      )
    end

    def round_trips?(source:)
      parser = Unparser.parser

      local_variable_scope
        .local_variables_for_node(node)
        .each(&parser.static_env.public_method(:declare))

      node.eql?(parser.parse(Unparser.buffer(source)))
    rescue Parser::SyntaxError
      false
    end
  end # Writer
end # Unparser
