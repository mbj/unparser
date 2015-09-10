module Unparser
  class Emitter
    # Emitter for rescue body nodes
    class Resbody < self

      children :exception, :assignment, :body

      # Emitter for resbody in standalone form
      class Standalone < self

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          write(K_RESCUE, WS)
          visit_plain(body)
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
      end

      # Emitter for resbody in keyworkd-embedded form
      class Embedded < self

        handle :resbody

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
          emit_body
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
    end
  end # Emitter
end # Unparser
