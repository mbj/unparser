module Unparser
  class Emitter

    # Emitter for zsuper nodes
    class ZSuper < self
      include Terminated

      handle :zsuper

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_SUPER)
      end

    end # ZSuper

    # Emitter for super nodes
    class Super < self
      include Terminated

      handle :super

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_SUPER)
        parentheses do
          delimited(children)
        end
      end

    end # Super

  end # Emitter
end # Unparser
