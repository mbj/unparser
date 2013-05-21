module Unparser
  class Emitter
    class Case < self

      handle :case

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_CASE)
        emit_condition
        emit_whens
        emit_else
        k_end
      end

      # Emit else
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_else
        else_branch = children.last
        return unless else_branch
        write(K_ELSE)
        indented { visit(else_branch) }
      end

      # Emit whens
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_whens
        nl
        children[1..-2].each do |child|
          visit(child)
        end
      end

      # Emit condition
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_condition
        condition = first_child
        return unless condition
        write(WS)
        visit(condition)
      end

    end # Case

    class When < self

      handle :when

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_WHEN, WS)
        delimited(children[0..-2])
        indented { visit(children.last) }
      end

    end
  end # Emitter
end # Unparser
