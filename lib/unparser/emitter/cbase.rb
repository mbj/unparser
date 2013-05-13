module Unparser
  class Emitter
    # Emitter for toplevel constant reference nodes
    class CBase < self
      BASE = '::'.freeze

      handle :cbase

      # Perform dispatch
      #
      # @param [Parser::AST::Node] node
      # @param [Buffer] buffer
      #
      # @return [self]
      #
      # @api private
      #
      def self.emit(node, buffer)
        buffer.append(BASE)
      end

    end # CBase
  end # Emitter
end # Unparser
