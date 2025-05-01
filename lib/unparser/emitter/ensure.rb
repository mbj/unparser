# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for ensure nodes
    class Ensure < self
      handle :ensure

    private

      def dispatch
        emit_ensure(node)
      end
    end # Ensure
  end # Emitter
end # Unparser
