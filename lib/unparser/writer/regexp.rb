# frozen_string_literal: true

module Unparser
  module Writer
    # Writer for regexp literals
    class Regexp
      include Writer, Adamantium

      CANDIDATES = [
        ['/', '/'].freeze,
        ['%r{', '}'].freeze
      ].freeze

      define_group(:body, 0..-2)

      def dispatch
        effective_writer.write_to_buffer
      end

    private

      # mutant:disable
      def effective_writer
        CANDIDATES.each do |token_open, token_close|
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

        def dispatch
          buffer.root_indent do
            write(token_open)
            body.each(&method(:emit_body))
            write(token_close)
            emit_options
          end
        end

      private

        def emit_body(node)
          if n_begin?(node)
            write('#{')
            node.children.each(&method(:visit))
            write('}')
          else
            write_regular(node.children.first)
          end
        end

        def write_regular(string)
          if string.length > 1 && string.start_with?("\n")
            string.each_char do |char|
              buffer.append_without_prefix(char.eql?("\n") ? '\c*' : char)
            end
          else
            buffer.append_without_prefix(string)
          end
        end

        def emit_options
          write(children.last.children.join)
        end
      end

      # mutant:disable
      def render_with_delimiter(token_close:, token_open:)
        buffer = Buffer.new

        writer = Effective.new(
          buffer:,
          comments:,
          explicit_encoding:,
          local_variable_scope:,
          node:,
          token_close:,
          token_open:
        )

        writer.dispatch
        buffer.nl_flush_heredocs
        buffer.content
      end
    end # Regexp
  end # Emitter
end # Unparser
