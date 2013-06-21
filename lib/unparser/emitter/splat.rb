module Unparser
  class Emitter
    # Emitter for splats
    class Splat < self

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
