module Unparser
  class Emitter
    # Emitter for undef nodes
    class Undef < self

      handle :undef

      K_UNDEF = 'undef'.freeze

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_UNDEF)
        ws
        visit(first_child)
      end

    end # Undef
  end # Emitter
end # Unparser
