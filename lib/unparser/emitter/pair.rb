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
          unless implicit_value_lvar? || implicit_value_send?
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

      def key_value
        key.children.first
      end

      def implicit_value_lvar?
        n_lvar?(value) && value.children.first.equal?(key_value)
      end

      def implicit_value_send?
        children = value.children

        n_send?(value) \
          && !key_value.end_with?('?') \
          && !key_value.end_with?('!') \
          && children.fetch(0).nil? \
          && children.fetch(1).equal?(key_value) \
          && children.at(2).nil?
      end
    end
  end
end
