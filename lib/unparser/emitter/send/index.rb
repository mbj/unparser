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
          emit_operation
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
          include Terminated

        private

          # Emit arguments
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_operation
            parentheses(*INDEX_PARENS) do
              delimited_plain(arguments)
            end
          end
        end # Reference

        # Emitter for assign to index nodes
        class Assign < self
          include Unterminated

          # Test if assign will be emitted terminated
          #
          # @return [Boolean]
          #
          # @api private
          #
          def terminated?
            mlhs?
          end

        private

          define_group(:indices, 2..-2)
          define_child(:value, -1)

          # Emit arguments
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_operation
            if arguments.empty?
              emit_regular_with_empty_args
            elsif mlhs?
              emit_mlhs_operation
            else
              emit_normal_operation
            end
          end

          # Emit mlhs arguments
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_mlhs_operation
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
          def emit_normal_operation
            parentheses(*INDEX_PARENS) do
              delimited_plain(indices)
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
