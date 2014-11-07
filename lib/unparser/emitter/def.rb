# encoding: utf-8

module Unparser
  class Emitter
    # Emitter for def node
    class Def < self
      include LocalVariableRoot, Terminated

    private

      # Emit name
      #
      # @return [undefined]
      #
      # @api private
      #
      abstract_method :emit_name
      private :emit_name

      # Return body node
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      abstract_method :body
      private :body

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_DEF, WS)
        emit_name
        comments.consume(node, :name)
        emit_arguments
        emit_body
        k_end
      end

      # Emit arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_arguments
        return if arguments.children.empty?
        visit_parentheses(arguments)
      end

      # Instance def emitter
      class Instance < self

        handle :def

        children :name, :arguments, :body

      private

        # Emit name
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_name
          write(name.to_s)
        end

      end # Instance

      # Emitter for defines on singleton
      class Singleton < self

        handle :defs

        children :subject, :name, :arguments, :body

      private

        # Return mame
        #
        # @return [String]
        #
        # @api private
        #
        def emit_name
          conditional_parentheses(!subject_without_parens?) do
            visit(subject)
          end
          write(T_DOT, name.to_s)
        end

        # Test if subject needs parentheses
        #
        # @return [Boolean]
        #
        # @api private
        #
        def subject_without_parens?
          case subject.type
          when :self
            true
          when :const
            !subject.children.first
          when :send
            receiver, _selector, *arguments = *subject
            !receiver && arguments.empty?
          else
            false
          end
        end

      end # Singleton
    end # Def
  end # Emitter
end # Unparser
