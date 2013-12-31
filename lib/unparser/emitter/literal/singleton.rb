# encoding: utf-8

module Unparser
  class Emitter
    class Literal
      # Emiter for literal singletons
      class Singleton < self

        handle :self, :true, :false, :nil

      private

        # Perform dispatco
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          buffer.append(node.type.to_s)
        end

      end # Singleton
    end # Literal
  end # Emitter
end # Unparser
