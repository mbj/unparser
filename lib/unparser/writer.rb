# frozen_string_literal: true

module Unparser
  module Writer
    include Generation, NodeHelpers

    # mutant:disable
    def self.included(descendant)
      descendant.class_eval do
        include Adamantium, Anima.new(:buffer, :comments, :explicit_encoding, :node, :local_variable_scope)

        extend DSL
      end
    end

  private

    # mutant:disable
    def emitter(node)
      Emitter.emitter(
        buffer:               buffer,
        comments:             comments,
        explicit_encoding:    explicit_encoding,
        local_variable_scope: local_variable_scope,
        node:                 node
      )
    end

    # mutant:disable
    def round_trips?(source:)
      parser = Unparser.parser

      local_variable_scope
        .local_variables_for_node(node)
        .each(&parser.static_env.public_method(:declare))

      buffer = Buffer.new
      buffer.write_encoding(explicit_encoding) if explicit_encoding
      buffer.write(source)

      node.eql?(parser.parse(Unparser.buffer(buffer.content)))
    rescue Parser::SyntaxError
      false
    end
  end # Writer
end # Unparser
