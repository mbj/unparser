module Unparser
  class Emitter
    # Emitter for rescue nodes
    class Rescue < self

      handle :rescue

      children :body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        if body
          visit_indented(body)
        else
          nl
        end
        rescue_bodies.each do |child|
          visit(child)
        end
        emit_else
      end

      # Return rescue bodies
      #
      # @return [Enumerable<Parser::AST::Node>]
      #
      # @api private
      #
      def rescue_bodies
        children[1..-2]
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
