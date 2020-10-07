# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for Hash literals
    class Hash < self
      BAREWORD = /\A[A-Za-z_][A-Za-z_0-9]*[?!]?\z/.freeze

      private_constant(*constants(false))

      handle :hash

      def emit_last_argument_hash
        if children.empty?
          write('{}')
        else
          emit_hash_body
        end
      end

      def emit_heredoc_reminders
        children.each(&method(:emit_heredoc_reminder_member))
      end

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

      def emit_heredoc_reminder_member(node)
        emitter(node.children.last).emit_heredoc_reminders
      end

      def emit_hash_body
        delimited(children, &method(:emit_hash_member))
      end

      def emit_hash_member(node)
        if n_kwsplat?(node)
          visit(node)
        else
          emit_pair(node)
        end
      end

      def emit_pair(pair)
        key, value = *pair.children

        if colon?(key)
          write(key.children.first.to_s, ': ')
        else
          visit(key)
          write(' => ')
        end

        visit(value)
      end

      def colon?(key)
        n_sym?(key) && BAREWORD.match?(key.children.first)
      end

    end # Hash
  end # Emitter
end # Unparser
