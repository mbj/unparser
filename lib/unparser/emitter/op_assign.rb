module Unparser
  class Emitter

    # Emitter for and assign
    class AndAssign < self

      handle :and_asgn

      AND_ASGN = '&&='.freeze

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        visit(first_child)
        write(WS, AND_ASGN, WS)
        visit(children[1])
      end

    end # OrAssign

    # Emitter for or assign
    class OrAssign < self

      handle :or_asgn

      OR_ASGN = '||='.freeze

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        visit(first_child)
        write(WS, OR_ASGN, WS)
        visit(children[1])
      end

    end # OrAssign

    # Emitter for op assign
    class OpAssign < self

      handle :op_asgn

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        visit(first_child)
        write(WS, children[1].to_s, O_ASN, WS)
        visit(children[2])
      end

    end # OpAssign
  end # Emitte
end # Unparser
