module Unparser
  class Emitter
    # Root emitter a special case
    class Root < self
      include Concord::Public.new(:buffer, :comments)

      # Return root node type
      #
      # @return [nil]
      #
      # @api private
      #
      def node_type
        nil
      end

    end # Root
  end # Emitter
end # Unparser
