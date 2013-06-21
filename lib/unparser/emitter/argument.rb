module Unparser
  class Emitter

    # Arg expr (pattern args) emitter
    class ArgExpr < self

      handle :arg_expr

      children :body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        parentheses do
          visit(body)
        end
      end
    end # ArgExpr

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
        mapped = children.map do |child|
          if child.type == :mlhs
            Parser::AST::Node.new(:arg_expr, [child])
          else
            child
          end
        end
        delimited(mapped)
      end

    end # Arguments

    # Emitter for block arguments
    class Blockarg < self

      handle :blockarg

      children :name

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(O_AMP, name.to_s)
      end

    end # Blockarg

    # Optional argument emitter
    class Optarg < self

      handle :optarg

      children :name, :value

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(name.to_s, WS, O_ASN, WS)
        visit(value)
      end
    end

    # Keyword rest argument emitter
    class KeywordRest < self

      handle :kwrestarg

      children :name

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(O_DSPLAT, name.to_s)
      end
    end # KeywordRest

    # Optional keyword argument emitter
    class KeywordOptional < self
      handle :kwoptarg

      children :name, :value

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(name.to_s, O_COLON, WS)
        visit(value)
      end

    end # KeywordOptional

    # Keyword argument emitter
    class Kwarg < self
      handle :kwarg

      children :name

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(name.to_s, O_COLON)
      end

    end # Restarg

    # Rest argument emitter
    class Restarg < self

      handle :restarg

      children :name

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(O_SPLAT, name.to_s)
      end

    end # Restarg

    # Argument emitter
    class Argument < self

      handle :arg

      children :name

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(name.to_s)
      end

    end # Argument

    # Block pass node emitter
    class BlockPass < self

      handle :block_pass

      children :name

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(O_AMP)
        visit(name)
      end

    end # BlockPass

  end # Emitter
end # Unparser
