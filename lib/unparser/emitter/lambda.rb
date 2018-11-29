# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for lambda nodes
    class Lambda < self
      include Terminated

      handle :lambda

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write('->')
      end

    end # Lambda
  end # Emitter
end # Unparser
