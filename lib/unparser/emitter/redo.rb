module Unparser
  class Emitter
    # Emitter for redo nodes
    class Redo < self
      include Terminated

      handle :redo

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_REDO)
      end

    end # Redo
  end # Emitter
end # Unparser
