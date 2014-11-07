# encoding: utf-8

module Unparser
  class Emitter
    # Emitter for defined? nodes
    class Defined < self
      include Terminated

      handle :defined?

      children :subject

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_DEFINED)
        parentheses do
          visit(subject)
        end
      end

    end # Defined
  end # Emitter
end # Unparser
