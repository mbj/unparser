module Unparser
  class Emitter

    # Base class for assignment emitters
    class Assignment < self

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_left
        emit_right
      end

      # Single assignment emitter
      class Single < self

        # Emit right
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_right
          right = right_node
          if right
            write(WS, T_ASN, WS)
            visit(right)
          end
        end

        abstract_method :emit_left

        # Variable assignment emitter
        class Variable < self

          handle :lvasgn, :ivasgn, :cvasgn, :gvasgn

          children :name, :right_node

        private

          # Emit left
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_left
            write(name.to_s)
          end

        end # Variable

        # Constant assignment emitter
        class Constant < self


          handle :casgn

          children :base, :name, :right_node

        private

          # Emit left
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_left
            if base
              visit(base)
              write(T_DCL)
            end
            write(name.to_s)
          end

        end # Constant
      end # Single

      # Multiple assignment
      class Multiple < self

        handle :masgn

      private

        # Emit left
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_left
          visit(first_child)
        end

        # Emit right
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_right
          write(WS, T_ASN, WS)
          right = children.last
          case right.type
          when :array
            delimited(right.children)
          else
            visit(right)
          end
        end

      end # Multiple

      # Emitter for multiple assignment left hand side
      class MLHS < Emitter

        handle :mlhs

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          maybe_parentheses(parent_type == :mlhs) do
            delimited(children)
          end
        end

      end # MLHS

    end # Assignment
  end # Emitter
end # Unparser
