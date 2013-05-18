module Unparser
  class Emitter

    # Arguments emitter
    class Arguments < self

      handle :args

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

    end # Arguments

    # Emitter for block arguments
    class Blockarg < self

      handle :blockarg

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(O_AMP, first_child.to_s)
      end

    end # Blockarg

    # Optional argument emitter
    class Optarg < self

      handle :optarg

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(first_child.to_s, WS, O_ASN, WS)
        visit(children[1])
      end
    end

    # Rest argument emitter
    class Restarg < self
      handle :restarg

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(O_SPLAT, first_child.to_s)
      end

    end # Restarg

    # Argument emitter
    class Argument < self

      handle :arg

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(first_child.to_s)
      end

    end # Argument

    # Block pass node emitter
    class BlockPass < self

      handle :block_pass

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(O_AMP)
        visit(first_child)
      end

    end # BlockPass

  end # Emitter
end # Unparser
