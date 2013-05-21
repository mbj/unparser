module Unparser
  class Emitter

    # Base class for and and or op-assign
    class BinaryAssign < self

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        visit(first_child)
        write(WS, self.class::KEYWORD, WS)
        visit(children[1])
      end

      # Emitter for binary and assign
      class And < self
        KEYWORD = '&&='.freeze
        handle :and_asgn
      end # And

      # Emitter for binary or assign
      class Or < self
        KEYWORD = '||='.freeze
        handle :or_asgn
      end # Or

    end # BinaryAssign

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
