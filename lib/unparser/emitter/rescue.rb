module Unparser
  class Emitter
    # Emitter for rescue nodes
    class Rescue < self
      include Unterminated

      handle :rescue

      children :body, :rescue_body

      define_group :rescue_bodies, 1..-2

      EMBEDDED_TYPES = [:def, :defs, :kwbegin, :ensure].to_set.freeze

      NOINDENT_STANDALONE_RESCUE = [:root, :begin, :pair_rocket, :pair_colon, :lvasgn, :ivasgn].to_set.freeze

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        if standalone?
          if NOINDENT_STANDALONE_RESCUE.include?(parent_type)
            emit_standalone
          else
            indented { emit_standalone }
          end
        else
          emit_embedded
        end
      end

      # Test if rescue node ist standalone
      #
      # @return [Boolean]
      #
      # @api private
      #
      def standalone?
        if parent_type.equal?(:ensure)
          !parent.node.children.first.equal?(node)
        else
          !EMBEDDED_TYPES.include?(parent_type)
        end
      end

      # Emit standalone form
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_standalone
        visit_plain(body)
        ws
        run(Resbody::Standalone, rescue_body)
      end

      # Emit embedded form
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_embedded
        if body
          visit_indented(body)
        else
          nl
        end
        rescue_bodies.each do |child|
          run(Resbody::Embedded, child)
        end
        emit_else
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
  end # Emitter
end # Unparser
