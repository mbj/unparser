# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for send to index references
    #
    # ignore :reek:RepeatedConditional
    class Index < self

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_receiver
        emit_operation
      end

    private

      # Emit receiver
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_receiver
        visit(first_child)
      end

      # Test for mlhs
      #
      # @return [Boolean]
      #
      # @api private
      #
      def mlhs?
        parent_type.equal?(:mlhs)
      end

      class Reference < self
        include Terminated

        define_group(:indices, 1..-1)

        handle :index

      private

        # Emit arguments
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_operation
          parentheses(*BRACKETS_SQUARE) do
            delimited_plain(indices)
          end
        end
      end # Reference

      # Emitter for assign to index nodes
      class Assign < self

        handle :indexasgn

        VALUE_RANGE     = (1..-2).freeze
        NO_VALUE_PARENT = IceNine.deep_freeze(%i[and_asgn op_asgn or_asgn].to_set)

        # Test if assign will be emitted terminated
        #
        # @return [Boolean]
        #
        # @api private
        #
        def terminated?
          !emit_value?
        end

      private

        # Emit arguments
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_operation
          parentheses(*BRACKETS_SQUARE) do
            delimited_plain(indices)
          end

          if emit_value?
            write(WS, T_ASN, WS)
            visit(children.last)
          end
        end

        # The indices
        #
        # @return [Array<Parser::AST::Node>]
        #
        def indices
          if emit_value?
            children[VALUE_RANGE]
          else
            children.drop(1)
          end
        end

        # Test if value should be emitted
        #
        # @return [Boolean]
        #
        # @api private
        #
        def emit_value?
          !mlhs? && !no_value_parent?
        end

        # Test for no value parent
        #
        # @return [Boolean]
        #
        # @api private
        #
        def no_value_parent?
          NO_VALUE_PARENT.include?(parent_type)
        end
      end # Assign
    end # Index
  end # Emitter
end # Unparser
