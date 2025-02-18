# frozen_string_literal: true

module Unparser
  class Emitter

    # Emitter for begin nodes
    class Begin < self
      handle :begin
      children :body

    private

      def dispatch
        parentheses do
          delimited(children, '; ')
        end
      end
    end # Begin
  end # Emitter
end # Unparser
