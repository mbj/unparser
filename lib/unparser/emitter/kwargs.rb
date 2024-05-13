# frozen_string_literal: true

module Unparser
  class Emitter
    class Kwargs < self
      handle :kwargs

      def emit_heredoc_remainders
        children.each do |child|
          emitter(child).emit_heredoc_remainders
        end
      end

      def dispatch
        delimited(children)
      end
    end # Kwargs
  end # Emitter
end # Unparser
