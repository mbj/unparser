# frozen_string_literal: true

module Unparser
  module Writer
    class DynamicString
      include Writer, Adamantium

      FLAT_INTERPOLATION = %i[ivar cvar gvar nth_ref].to_set.freeze

      # Amount of dstr children at which heredoc emitting is
      # preferred, but not guaranteed.
      HEREDOC_THRESHOLD = 8
      HEREDOC_DELIMITER = 'HEREDOC'
      HEREDOC_HEADER    = "<<-#{HEREDOC_DELIMITER}".freeze
      HEREDOC_FOOTER    = "#{HEREDOC_DELIMITER}\n".freeze

      private_constant(*constants(false))

      # The raise below is not reachable if unparser is correctly implemented
      # but has to exist as I have to assume unparser still has bugs.
      #
      # But unless I had such a bug in my test corpus: I cannot enable mutant, and if I
      # knew about such a bug: I'd fix it so would be back at the start.
      #
      # TLDR: Good case for a mutant disable.
      #
      # mutant:disable
      def dispatch
        if heredoc?
          write(HEREDOC_HEADER)
          buffer.push_heredoc(heredoc_body)
        elsif round_tripping_segmented_source
          write(round_tripping_segmented_source)
        else
          fail UnsupportedNodeError, "Unparser cannot round trip this node: #{node.inspect}"
        end
      end

    private

      def heredoc?
        if children.length >= HEREDOC_THRESHOLD
          round_trips_heredoc?
        else
          round_tripping_segmented_source.nil? # && round_trips_heredoc?
        end
      end
      memoize :heredoc?

      def round_trips_heredoc?
        round_trips?(source: heredoc_source)
      end
      memoize :round_trips_heredoc?

      def round_tripping_segmented_source
        each_segments(children) do |segments|

          source = segmented_source(segments: segments)

          return source if round_trips?(source: source)
        end
        nil
      end
      memoize :round_tripping_segmented_source

      def each_segments(array)
        yield [array]

        1.upto(array.length) do |take|
          prefix = [array.take(take)]
          suffix = array.drop(take)
          each_segments(suffix) do |items|
            yield(prefix + items)
          end
        end
      end

      def segmented_source(segments:)
        buffer = Buffer.new

        Segmented.new(
          buffer:,
          comments:,
          explicit_encoding:    nil,
          local_variable_scope:,
          node:,
          segments:
        ).dispatch

        buffer.content
      end

      def heredoc_body
        buffer = Buffer.new

        writer = Heredoc.new(
          buffer:,
          comments:,
          explicit_encoding:    nil,
          local_variable_scope:,
          node:
        )

        writer.emit
        buffer.content
      end
      memoize :heredoc_body

      def heredoc_source
        "#{HEREDOC_HEADER}\n#{heredoc_body}"
      end
      memoize :heredoc_source

      class Heredoc
        include Writer, Adamantium

        def emit
          emit_heredoc_body
          write(HEREDOC_FOOTER)
        end

      private

        def emit_heredoc_body
          children.each do |child|
            if n_str?(child)
              write(escape_dynamic(child.children.first))
            else
              emit_dynamic(child)
            end
          end
        end

        def escape_dynamic(string)
          string.gsub('#', '\#')
        end

        def emit_dynamic(child)
          write('#{')
          emit_dynamic_component(child.children.first)
          write('}')
        end

        def emit_dynamic_component(node)
          visit(node) if node
        end
      end # Heredoc

      class Segmented
        include Writer, Adamantium

        include anima.add(:segments)

        def dispatch
          if children.empty?
            write('%()')
          else
            segments.each_with_index { |segment, index| emit_segment(segment, index) }
          end
        end

      private

        def emit_segment(children, index)
          write(' ') unless index.zero?

          write('"')
          emit_segment_body(children)
          write('"')
        end

        def emit_segment_body(children)
          children.each_with_index do |child, index|
            case child.type
            when :begin
              write('#{')
              visit(child.children.first) if child.children.first
              write('}')
            when FLAT_INTERPOLATION
              write('#')
              visit(child)
            when :str
              visit_str(children, child, index)
            when :dstr
              emit_segment_body(child.children)
            end
          end
        end

        def visit_str(children, child, index)
          string = child.children.first

          next_child = children.at(index.succ)

          if next_child && next_child.type.equal?(:str)
            write(string.gsub('"', '\\"'))
          else
            write(child.children.first.inspect[1..-2])
          end
        end
      end
    end # DynamicString
  end # Writer
end # Unparser
