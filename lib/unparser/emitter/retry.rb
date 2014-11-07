# encoding: utf-8

module Unparser
  class Emitter
    # Emitter for retry nodes
    class Retry < self
      include Terminated

      handle :retry

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_RETRY)
      end

    end # Break
  end # Emitter
end # Unparser
