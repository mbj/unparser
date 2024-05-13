# frozen_string_literal: true

module Unparser
  class Emitter
    class Root < self
      END_NL = %i[class sclass module begin].freeze

      private_constant(*constants(false))

      def dispatch
        if children.any?
          emit_body(node, indent: false)
        else
          visit_deep(node)
        end

        emit_eof_comments

        nl if END_NL.include?(node.type) && !buffer.fresh_line?
      end
    end # Root
  end # Emitter
end # Unparser
