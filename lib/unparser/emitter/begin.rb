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
        childs = children
        max = childs.length - 1
        childs.each_with_index do |child, index|
          visit(child)
          nl if index < max
        end
      end

      # Emitter for implicit begins
      class Implicit < self

        handle :begin

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          if parentheses?
            parentheses { emit_inner }
          else
            emit_inner
          end
        end

        # Test if begin node needs to be enclosed within parentheses
        #
        # @return [true]
        #   if parentheses are needed
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def parentheses?
          children.length == 1 && children.first.type == :send && BINARY_OPERATORS.include?(children.first.children[1])
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
          if NOINDENT.include?(body.type)
            emit_inner
          else
            indented { emit_inner }
          end
        end

      end # Explicit

    end # Begin
  end # Emitter
end # Unparser
