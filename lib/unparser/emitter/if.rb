# encoding: utf-8

module Unparser
  class Emitter
    # Emitter if nodes
    class If < self
      handle :if

      children :condition, :if_branch, :else_branch

      def terminated?
        !postcondition?
      end

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        if postcondition?
          emit_postcondition
        else
          emit_normal
        end
      end

      # Test for postcondition
      #
      # @return [Boolean]
      #
      # @api private
      #
      def postcondition?
        return false unless if_branch.nil? ^ else_branch.nil?

        body = if_branch || else_branch

        local_variable_scope.first_assignment_in_body_and_used_in_condition?(body, condition)
      end

      # Emit in postcondition style
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_postcondition
        visit_plain(if_branch || else_branch)
        write(WS, keyword, WS)
        emit_condition
      end

      # Emit in normal style
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_normal
        write(keyword, WS)
        emit_condition
        emit_if_branch
        emit_else_branch
        k_end
      end

      # Test if AST can be emitted as unless
      #
      # @return [Boolean]
      #
      # @api private
      #
      def unless?
        !if_branch && else_branch
      end

      # Return keyword
      #
      # @return [String]
      #
      # @api private
      #
      def keyword
        unless? ? K_UNLESS : K_IF
      end

      # Emit condition
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_condition
        if condition.type.equal?(:match_current_line)
          visit_plain(condition)
        else
          visit(condition)
        end
      end

      # Emit if branch
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_if_branch
        if if_branch
          visit_indented(if_branch)
        end

        nl if !if_branch && !else_branch
      end

      # Emit else branch
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_else_branch
        return unless else_branch
        write(K_ELSE) unless unless?
        visit_indented(else_branch)
      end

    end # If
  end # Emitter
end # Unparser
