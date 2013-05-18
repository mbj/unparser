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

      O_BLOCK_PASS = '&'.freeze

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(O_BLOCK_PASS)
        write(first_child.to_s)
      end
    end # Blockarg

    # Optional argument emitter
    class Optarg < self

      handle :optarg

      O_ASSIGN = '='.freeze

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(first_child.to_s)
        ws
        write(O_ASSIGN)
        ws
        visit(children[1])
      end
    end

    # Rest argument emitter
    class Restarg < self
      SPLAT = '*'.freeze

      handle :restarg

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(SPLAT)
        write(first_child.to_s)
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

      PASS = '&'.freeze

      handle :block_pass

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(PASS)
        visit(first_child)
      end

    end # BlockPass

  end # Emitter
end # Unparser
