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

        # Emit block within square brackets
        #
        # @return [undefined]
        #
        # @api private
        #
        def brackets(&block)
          parentheses(*INDEX_PARENS, &block)
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
            brackets do
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
            index, *assignment = arguments
            brackets do
              delimited([index])
            end
            return if assignment.empty? # mlhs
            write(WS, T_ASN, WS)
            delimited(assignment)
          end

        end # Assign

      end # Index
    end # Send
  end # Emitter
end # Unparser
