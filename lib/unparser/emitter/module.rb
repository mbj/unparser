# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for module nodes
    class Module < self
      include LocalVariableRoot

      handle :module

      children :name, :body

    private

      def dispatch
        write_loc('module', node.location.keyword.to_range)
        write(' ')
        visit(name)
        emit_optional_body(body)
        k_end
      end

    end # Module
  end # Emitter
end # Unparser
