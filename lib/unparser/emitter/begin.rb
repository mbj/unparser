# encoding: utf-8

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
        children.each_with_index do |child, index|
          visit_plain(child)
          write(NL) if index < children.length - 1
        end
      end

      # Emitter for implicit begins
      class Implicit < self

        handle :begin

        # Test if begin is terminated
        #
        # @return [Boolean]
        #
        # @api private
        #
        def terminated?
          children.empty?
        end

        TERMINATING_PARENT = [:root, :dyn_str_body].to_set.freeze

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          if terminated? && !TERMINATING_PARENT.include?(parent_type)
            write('()')
          else
            emit_inner
          end
        end

      end # Implicit

      # Emitter for explicit begins
      class Explicit < self
        include Terminated

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
          case
          when body.nil?
            nl
          when NOINDENT.include?(body.type)
            emit_inner
          else
            indented { emit_inner }
          end
        end

      end # Explicit

    end # Begin
  end # Emitter
end # Unparser
