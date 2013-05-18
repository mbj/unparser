module Unparser
  class Emitter

    # Base class for assignment emitters
    class Assignment < self
      OPERATOR = ' = '.freeze

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
            write(OPERATOR)
            visit(right) 
          end
        end

        abstract_method :emit_left

        # Variable assignment emitter
        class Variable < self 

          handle :lvasgn, :ivasgn, :cvasgn, :gvasgn

        private

          # Emit left
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_left
            write(first_child.to_s)
          end

          # Return right node
          #
          # @return [Parser::AST::Node]
          #
          # @api private
          #
          def right_node
            children[1]
          end
        end

        # Constant assignment emitter
        class Constant < self

          handle :casgn

        private

          # Return right node
          #
          # @return [Parser::AST::Node]
          #
          # @api private
          #
          def right_node
            children[2]
          end

          # Emit left
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_left
            emit_base
            write(children[1].to_s)
          end

          # Emit base
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_base
            base = first_child
            visit(base) if base
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
          write(OPERATOR)
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
          delimited(children)
        end
      end # MultipleLeftHandSide

    end # Assignment
  end # Emitter
end # Unparser
