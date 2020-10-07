# frozen_string_literal: true

module Unparser
  class Emitter
    # Root emitter a special case
    class Root < self
      include Concord::Public.new(:buffer, :node, :comments)
      include LocalVariableRoot

      def dispatch
        if children.any?
          emit_body(node, indent: false)
        else
          visit_deep(node)
        end

        emit_eof_comments
        nl
      end
    end # Root
  end # Emitter
end # Unparser
