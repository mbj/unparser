# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for key value pairs in hash literals or kwargs
    class Pair < self
      BAREWORD = /\A[A-Za-z_][A-Za-z_0-9]*[?!]?\z/.freeze

      private_constant(*constants(false))

      handle :pair

      children :key, :value

    private

      def dispatch
        if colon?
          emit_colon
          unless implicit_value?
            write(' ')
            visit(value)
          end
        else
          visit(key)
          write(' => ')
          visit(value)
        end
      end

      def colon?
        n_sym?(key) && BAREWORD.match?(key.children.first)
      end

      def emit_colon
        write(key.children.first.to_s, ':')
      end

      def implicit_value?
        n_lvar?(value) && value.children.first.equal?(key.children.first)
      end
    end
  end
end
