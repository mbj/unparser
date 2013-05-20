module Unparser
  class Emitter
    # Emitter for send
    class Send < self

      handle :send

      INDEX_PARENS  = IceNine.deep_freeze(%w([ ]))
      NORMAL_PARENS = IceNine.deep_freeze(%w[( )])

      INDEX_REFERENCE = '[]'.freeze
      INDEX_ASSIGN    = '[]='.freeze
      ASSIGN_SUFFIX   = '='.freeze

      AMBIGOUS = [:irange, :erange].to_set.freeze

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        case selector
        when INDEX_REFERENCE
          run(Index::Reference)
        when INDEX_ASSIGN
          run(Index::Assign)
        else
          non_index_dispatch
        end
      end

      # Emit unambigous receiver
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_unambigous_receiver
        receiver = first_child
        if receiver.type == :begin && receiver.children.length == 1
          receiver = receiver.children.first
        end
        if AMBIGOUS.include?(receiver.type)
          parentheses { visit(receiver) }
          return
        end

        visit(receiver)
      end

      # Delegate to emitter
      #
      # @param [Class:Emitter] emitter
      #
      # @return [undefined]
      #
      # @api private
      #
      def run(emitter)
        emitter.emit(node, buffer)
      end
      
      # Perform non index dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def non_index_dispatch
        emit_receiver
        emit_selector
        emit_arguments
      end

      # Return receiver
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def emit_receiver
        return unless first_child
        emit_unambigous_receiver
        write(O_DOT) 
      end

      # Emit selector
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_selector
        name = selector
        if mlhs?
          name = name[0..-2]
        end
        write(name)
      end

      # Test for mlhs
      #
      # @return [true]
      #   if node is within an mlhs
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def mlhs?
        assignment? && !arguments?
      end

      # Test for assigment
      #
      # @return [true]
      #   if node represents attribute / element assignment
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def assignment?
        selector[-1] == ASSIGN_SUFFIX
      end

      # Return selector
      #
      # @return [String]
      #
      # @api private
      #
      def selector
        children[1].to_s
      end
      memoize :selector

      # Test for empty arguments
      #
      # @return [true]
      #   if arguments are empty
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def arguments?
        arguments.any?
      end

      # Return argument nodes
      #
      # @return [Array<Parser::AST::Node>]
      #
      # @api private
      #
      def arguments
        children[2..-1]
      end

      # Emit arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_arguments
        args = arguments
        return if args.empty?
        parentheses do
          delimited(args)
        end
      end

      class Index < self

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_receiver
          emit_arguments
        end

        # Emit block within parentheses
        #
        # @return [undefined]
        #
        # @api private
        #
        def parentheses(&block)
          super(*INDEX_PARENS, &block)
        end

        # Emit receiver
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_receiver
          visit(first_child)
        end

        class Reference < self

        private

          # Emit arguments
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_arguments
            parentheses do
              delimited(arguments)
            end
          end
        end # Reference

        class Assign < self

          # Emit arguments
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_arguments
            index, *assignment = arguments
            parentheses do
              delimited([index])
            end
            return if assignment.empty? # mlhs
            write(WS, O_ASN, WS)
            delimited(assignment)
          end
        end # Assign
      end # Index

    end # Send
  end # Emitter
end # Unparser
