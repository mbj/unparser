module Unparser
  class Emitter

    class Rescue < self

      handle :rescue

      def dispatch
        write('begin')
        indent
        nl
        visit(children.first)
        nl
        unindent
        children[1..-2].each do |child|
          visit(child)
        end
        write('end')
      end
    end

    class Ensure < self
      handle :ensure

      def dispatch
        write('begin')
        nl
        indented { visit(children[0]) }
        nl
        write('ensure')
        nl
        indented { visit(children[1]) }
        nl
        write('end')
      end
    end

    class Resbody < self
      handle :resbody

      def dispatch
        write('rescue')
        emit_exception
        emit_assignment
        nl
        indent
        visit(children[2])
        nl
        unindent
      end

      def emit_exception
        exception = children[0]
        return unless exception
        write(' ')
        delimited(exception.children)
      end

      def emit_assignment
        assignment = children[1]
        return unless assignment
        write(' => ')
        visit(assignment)
      end
    end


    # Emitter for begin nodes
    class Body < self

      handle :begin

      def begin_single?
        children.length == 1 && [:rescue, :ensure].include?(children.first.type)
      end

      def dispatch
        if begin_single?
          visit(children.first)
          return
        end
        write('begin')
        nl
        indent
        emit_inner
        unindent
        write('end')
      end

      def emit_inner
        max = children.length
        children.each_with_index do |child, index|
          visit(child)
          nl if index < max
        end
      end
    end
  end # Emitter
end # Unparser
