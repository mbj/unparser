# encoding: utf-8

module Unparser
  class Emitter
    # Emitter for splats
    class KwSplat < self
      include Terminated

      handle :kwsplat

      children :subject

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(T_SPLAT, T_SPLAT)
        visit(subject)
      end
    end

    # Emitter for splats
    class Splat < self
      include Terminated

      handle :splat

      children :subject

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(T_SPLAT)
        visit(subject) if subject
      end
    end
  end
end # Unparser
