module Unparser
  class Emitter

    # Rest argument emitter
    class Restarg < self
      SPLAT = '*'.freeze

      handle :restarg

    protected

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
