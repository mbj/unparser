module Unparser
  class Emitter

    # Emitter for yield node
    class Yield < self
      include Terminated

      handle :yield

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_YIELD)
        return if children.empty?
        parentheses do
          delimited(children)
        end
      end

    end # Yield

  end # Emitter
end # Unparser
