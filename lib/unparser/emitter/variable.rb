module Unparser
  class Emitter
    # Emitter for various variable accesses
    class Variable < self

      handle :ivar, :lvar, :cvar, :gvar, :back_ref

    private
     
      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(children.first.to_s)
      end

    end # Access

    # Emitter for nth_ref nodes (regexp captures)
    class NthRef < self

      PREFIX = '$'.freeze

      handle :nth_ref

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(PREFIX)
        write(children.first.to_s)
      end

    end # NthRef

  end # Emitter
end # Unparser
