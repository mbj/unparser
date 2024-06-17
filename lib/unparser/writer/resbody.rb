# frozen_string_literal: true

module Unparser
  module Writer
    # Writer for rescue bodies
    class Resbody
      include Writer

      OPERATORS = {
        csend: '&.',
        send:  '.'
      }.freeze

      children :exception, :assignment, :body

      def emit_postcontrol
        write(' rescue ')
        visit(body)
      end

      def emit_regular
        write('rescue')
        emit_exception
        emit_assignment
        emit_optional_body(body)
      end

    private

      def emit_exception
        return unless exception

        ws
        delimited(exception.children)
      end

      def emit_assignment
        return unless assignment

        write(' => ')

        case assignment.type
        when :send, :csend
          write_send_assignment
        when :indexasgn
          write_index_assignment
        else
          visit(assignment)
        end
      end

      def write_send_assignment
        details = NodeDetails::Send.new(assignment)

        visit(details.receiver)
        write(OPERATORS.fetch(assignment.type))
        write(details.non_assignment_selector)
      end

      def write_index_assignment
        receiver, index = assignment.children
        visit(receiver)
        write('[')
        visit(index) if index
        write(']')
      end
    end # Resbody
  end # Writer
end # Unparser
