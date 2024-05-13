# frozen_string_literal: true

module Unparser
  module Writer
    # Writer for regexp literals
    class Regexp
      include Writer, Adamantium

      CANDIDATES = [%w[/ /].freeze, %w[%r{ }].freeze].freeze

      define_group(:body, 0..-2)

      def emit_heredoc_remainders
        effective_writer.emit_heredoc_remainders
      end

      def dispatch
        effective_writer.write_to_buffer
      end

    private

      def effective_writer
        CANDIDATES.each do |(token_open, token_close)|
          source = render_with_delimiter(token_close:, token_open:)

          next unless round_trips?(source:)

          return writer_with(Effective, node:, token_close:, token_open:)
        end

        fail 'Could not find a round tripping solution for regexp'
      end

      class Effective
        include Writer, Adamantium

        include anima.add(:token_close, :token_open)

        define_group(:body, 0..-2)

        def emit_heredoc_remainders
          body.each do |body|
            emitter(body).emit_heredoc_remainders
          end
        end

        def dispatch
          write(token_open)
          body.each(&method(:emit_body))
          write(token_close)
          emit_options
        end

      private

        def emit_body(node)
          if n_begin?(node)
            write('#{')
            node.children.each(&method(:visit))
            write('}')
          else
            buffer.append_without_prefix(node.children.first)
          end
        end

        def emit_options
          write(children.last.children.join)
        end
      end

    private

      def render_with_delimiter(token_close:, token_open:)
        buffer = Buffer.new

        writer = Effective.new(
          buffer:,
          comments:,
          local_variable_scope:,
          node:,
          token_close:,
          token_open:
        )

        writer.dispatch
        writer.emit_heredoc_remainders

        buffer.content.freeze
      end
    end # Regexp
  end # Emitter
end # Unparser
