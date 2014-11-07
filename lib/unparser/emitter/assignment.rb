# encoding: utf-8

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

        # Test for terminated emit
        #
        # @return [Boolean]
        #
        # @api private
        #
        def terminated?
          right_node.nil?
        end

      private

        # Emit right
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_right
          right = right_node
          return unless right
          write(WS, T_ASN, WS)
          visit(right)
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
              write(T_DCL) if base.type != :cbase
            end
            write(name.to_s)
          end

        end # Constant
      end # Single

      # Multiple assignment
      class Multiple < self
        include Unterminated

        handle :masgn

        PARENS = IceNine.deep_freeze(%w([ ]))

      private

        # Emit left
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_left
          visit_plain(first_child)
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
            children = right.children
            parentheses(*PARENS) do
              delimited(children)
            end
          else
            visit(right)
          end
        end

      end # Multiple

      # Emitter for multiple assignment left hand side
      class MLHS < Emitter
        include Unterminated

        handle :mlhs

      private

        NO_COMMA = [:splat, :restarg].to_set.freeze
        PARENT_MLHS = [:mlhs, :masgn]

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          delimited(children)

          write(',') if children.one? && mlhs?
        end

        # Test for mlhs context
        #
        # @return [undefined]
        #
        # @api private
        #
        def mlhs?
          !NO_COMMA.include?(first_child.type) && PARENT_MLHS.include?(parent_type)
        end

      end # MLHS

    end # Assignment
  end # Emitter
end # Unparser
