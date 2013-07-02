module Unparser
  class Emitter

    # Emitter for rescue nodes
    class Rescue < self

      handle :rescue

      children :body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        visit_indented(body)
        rescue_bodies.each do |child|
          visit(child)
        end
        emit_else
      end

      # Return rescue bodies
      #
      # @return [Enumerable<Parser::AST::Node>]
      #
      # @api private
      #
      def rescue_bodies
        children[1..-2]
      end

      # Emit else
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_else
        return unless else_branch
        write(K_ELSE)
        visit_indented(else_branch)
      end

      # Return else body
      #
      # @return [Parser::AST::Node]
      #   if else body is present
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def else_branch
        children.last
      end

    end # Rescue

    # Emitter for ensure nodes
    class Ensure < self

      handle :ensure

      children :body, :ensure_body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_body
        write(K_ENSURE)
        emit_ensure_body
      end

      # Emit body
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_body
        indented { visit(body) }
      end

      # Emit ensure body
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_ensure_body
        indented { visit(ensure_body) }
      end

    end # Ensure

    # Emitter for rescue body nodes
    class Resbody < self

      handle :resbody

      children :exception, :assignment, :body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_RESCUE)
        emit_exception
        emit_assignment
        if body
          indented { visit(body) }
        else
          nl
        end
      end

      # Emit exception
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_exception
        return unless exception
        ws
        delimited(exception.children)
      end

      # Emit assignment
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_assignment
        return unless assignment
        write(WS, T_ASR, WS)
        visit(assignment)
      end

    end # Resbody

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
          emit_inner
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
