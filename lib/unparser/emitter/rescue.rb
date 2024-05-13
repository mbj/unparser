# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for rescue nodes
    class Rescue < self
      handle :rescue

    private

      def dispatch
        resbody = children.fetch(1)

        if resbody.children.fetch(1)
          emit_rescue_regular(node)
        else
          emit_rescue_postcontrol(node)
        end
      end
    end # Rescue
  end # Emitter
end # Unparser
