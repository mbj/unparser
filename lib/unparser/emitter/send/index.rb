# encoding: utf-8

module Unparser
  class Emitter
    class Send
      # Emitter for send to index references
      class Index < self

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_receiver
          emit_arguments
        end

        # Emit receiver
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_receiver
          visit_terminated(first_child)
        end

        # Emitter for index reference nodes
        class Reference < self

        private

          # Emit arguments
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_arguments
            parentheses(*INDEX_PARENS) do
              delimited(arguments)
            end
          end
        end # Reference

        # Emitter for assign to index nodes
        class Assign < self

          # Emit arguments
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_arguments
            case arguments.length
            when 0
              emit_regular_with_empty_args
            when 1
              emit_mlhs_arguments
            else
              emit_normal_arguments
            end
          end

          # Emit mlhs arguments
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_mlhs_arguments
            parentheses(*INDEX_PARENS) do
              delimited(arguments)
            end
          end

          # Emit normal arguments
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_normal_arguments
            # Workaround bug in RBX causes to crash here on
            # *indices, value = arguments
            #
            # https://github.com/rubinius/rubinius/issues/3037
            indices, value = arguments[0..-2], arguments.last
            parentheses(*INDEX_PARENS) do
              delimited(indices)
            end
            write(WS, T_ASN, WS)
            visit(value)
          end

          # Emit regular with empty ars
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_regular_with_empty_args
            write(T_DOT, '[]=()')
          end

        end # Assign

      end # Index
    end # Send
  end # Emitter
end # Unparser
