# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for forward arguments
    class ForwardArgs < self

      handle :forward_args

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write('...')
      end

    end # ForwardArgs
  end # Emitter
end # Unparser
