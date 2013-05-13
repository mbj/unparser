module Unparser
  class Emitter
    class Assignment < self
      include InstanceEmitter

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
        write(OPERATOR)
        emit_right
      end

      # Emit right
      #
      # @return [undefined]
      # 
      # @api private
      #
      def emit_right
        visit(children.last)
      end

      abstract_method :emit_left

      class Variable < self 

        handle :lvasgn, :ivasgn, :cvasgn

      private

        # Emit left
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_left
          write(children.first.to_s)
        end
      end

      class Constant < self

        handle :casgn

      private

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
          base = children.first
          visit(base) if base
        end
      end

    end # Assignment
  end # Emitter
end # Unparser
