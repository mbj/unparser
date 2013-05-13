module Unparser
  class Emitter
    # Emitter for various variable accesses
    class Variable < self

      handle :ivar, :lvar, :cvar, :gvar
     
      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def self.emit(node, buffer)
        buffer.append(node.children.first.to_s)
        self
      end

    end # Access

    # Emitter for nth ref variable access
    class NthRef < self

      PREFIX = '$'.freeze

      handle :nth_ref

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def self.emit(node, buffer)
        buffer.append(PREFIX)
        buffer.append(node.children.first.to_s)
        self
      end

    end # NthRef
  end # Emitter
end # Unparser
