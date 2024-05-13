# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for Hash literals
    class Hash < self
      handle :hash

    private

      def dispatch
        if children.empty?
          write('{}')
        else
          parentheses('{', '}') do
            write(' ')
            emit_hash_body
            write(' ')
          end
        end
      end

      def emit_hash_body
        delimited(children)
      end
    end # Hash
  end # Emitter
end # Unparser
