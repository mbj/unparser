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
            if arguments.one?
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
            *indices, value = arguments
            parentheses(*INDEX_PARENS) do
              delimited(indices)
            end
            write(WS, T_ASN, WS)
            visit(value)
          end

        end # Assign

      end # Index
    end # Send
  end # Emitter
end # Unparser
