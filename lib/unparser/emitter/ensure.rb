module Unparser
  class Emitter

    # Emitter for ensure nodes
    class Ensure < self

      handle :ensure

      children :body, :ensure_body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        visit_indented(body)
        write(K_ENSURE)
        visit_indented(ensure_body)
      end

    end # Ensure
  end # Emitter
end # Unparser
