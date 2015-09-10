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
        if body
          visit_indented(body)
        else
          nl
        end
        write(K_ENSURE)
        if ensure_body
          visit_indented(ensure_body)
        else
          nl
        end
      end

    end # Ensure
  end # Emitter
end # Unparser
