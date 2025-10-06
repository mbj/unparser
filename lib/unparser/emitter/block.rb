# frozen_string_literal: true

module Unparser
  class Emitter

    # Block emitter
    class Block < self
      handle :block, :numblock, :itblock

      children :target, :arguments, :body

    private

      def dispatch
        emit_target
        ws
        write_open
        emit_block_arguments unless n_lambda?(target)
        emit_optional_body_ensure_rescue(body)
        write_close
      end

      def need_do?
        body && (n_rescue?(body) || n_ensure?(body))
      end

      def write_open
        if need_do?
          write('do')
        else
          write('{')
        end
      end

      def write_close
        if need_do?
          k_end
        else
          write('}')
        end
      end

      def target_writer
        writer_with(Writer::Send::Regular, node: target)
      end
      memoize :target_writer

      def emit_target
        case target.type
        when :send
          emit_send_target
        when :lambda
          visit(target)
          emit_lambda_arguments
        else
          visit(target)
        end
      end

      def emit_send_target
        target_writer.emit_receiver
        target_writer.emit_selector
        target_writer.emit_arguments_without_heredoc_body
      end

      # NOTE: mutant fails on Ruby < 3.4
      # mutant:disable
      def emit_lambda_arguments
        return if node.type.equal?(:numblock) || itblock?

        parentheses { writer_with(Args, node: arguments).emit_lambda_arguments }
      end

      def numblock?
        node.type.equal?(:numblock)
      end

      # NOTE: mutant fails on Ruby < 3.4
      # mutant:disable
      def itblock?
        node.type.equal?(:itblock)
      end

      # NOTE: mutant fails on Ruby < 3.4
      # mutant:disable
      def emit_block_arguments
        return if numblock? || itblock? || arguments.children.empty?

        ws

        parentheses('|', '|') do
          writer_with(Args, node: arguments).emit_block_arguments
        end
      end

    end # Block
  end # Emitter
end # Unparser
