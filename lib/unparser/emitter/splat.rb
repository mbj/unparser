# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for splats
    class KwSplat < self
      handle :kwsplat

      children :subject

    private

      def dispatch
        write('**')
        visit(subject)
      end
    end

    # Emitter for splats
    class Splat < self
      handle :splat

      children :subject

    private

      def dispatch
        write('*')
        visit(subject) if subject
      end
    end
  end
end # Unparser
