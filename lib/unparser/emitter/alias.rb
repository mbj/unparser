# encoding: utf-8

module Unparser
  class Emitter
    # Emitter for alias nodes
    class Alias < self

      handle :alias

      children :target, :source

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_ALIAS, WS)
        visit(target)
        write(WS)
        visit(source)
      end

    end # Alias
  end # Emitter
end # Unparser
