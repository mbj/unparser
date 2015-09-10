module Unparser
  class Emitter
    # Emitter for toplevel constant reference nodes
    class CBase < self
      include Terminated

      handle :cbase

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(T_DCL)
      end

    end # CBase
  end # Emitter
end # Unparser
