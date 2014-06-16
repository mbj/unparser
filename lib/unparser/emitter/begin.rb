# encoding: utf-8

module Unparser
  class Emitter

    # Emitter for begin nodes
    class Begin < self

      children :body

    private

      # Emit inner nodes
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_inner
        delimited(children, NL)
      end

      # Emitter for implicit begins
      class Implicit < self

        handle :begin

        NON_EMPTY_PARENS = [:root, :dstr, :dyn_str_body].to_set.freeze

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          if children.empty? && !NON_EMPTY_PARENS.include?(parent_type)
            write('()')
          else
            conditional_parentheses(parent_type.equal?(:optarg)) do
              emit_inner
            end
          end
        end

      end # Implicit

      # Emitter for explicit begins
      class Explicit < self

        handle :kwbegin

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          write(K_BEGIN)
          emit_body
          k_end
        end

        # Emit body
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_body
          case
          when body.nil?
            nl
          when NOINDENT.include?(body.type)
            emit_inner
          else
            indented { emit_inner }
          end
        end

      end # Explicit

    end # Begin
  end # Emitter
end # Unparser
