require 'abstract_type'
require 'concord'
require 'parser/all'

# Library namespace
module Unparser

  # Unparse ast into string
  #
  # @param [Parser::Node] node
  #
  # @return [String]
  #
  # @api private
  #
  def self.unparse(node)
    buffer = Buffer.new
    Emitter.visit(node, buffer)
    buffer.content
  end
end # Unparser

require 'unparser/buffer'
require 'unparser/emitter'

Unparser::Emitter::REGISTRY.freeze
