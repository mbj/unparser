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

        # Emit block within parentheses
        #
        # @return [undefined]
        #
        # @api private
        #
        def parentheses(&block)
          super(*INDEX_PARENS, &block)
        end

        # Emit receiver
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_receiver
          visit(first_child)
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
            parentheses do
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
            parentheses do
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
