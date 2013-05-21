module Unparser
  class Emitter

    # Emitter for yield node
    class Yield < self

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
        arguments = children
        return if arguments.empty?
        parentheses do
          delimited(arguments)
        end
      end

    end # Yield

  end # Emitter
end # Unparser
