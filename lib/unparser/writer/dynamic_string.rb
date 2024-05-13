# frozen_string_literal: true

module Unparser
  module Writer
    class DynamicString
      include Writer, Adamantium

      FLAT_INTERPOLATION = %i[ivar cvar gvar nth_ref].to_set.freeze

      # amount of dstr children at which heredoc emitting is
      # preferred, but not guaranteed.
      HEREDOC_THRESHOLD  = 8

      def emit_heredoc_remainder
        heredoc_writer.emit_heredoc_remainder if heredoc?
      end

      def dispatch
        if heredoc?
          heredoc_writer.emit_heredoc_header
        elsif round_tripping_segmented_source
          write(round_tripping_segmented_source)
        else
          fail UnsupportedNodeError, "Unparser cannot round trip this node: #{node.inspect}"
        end
      end

      class Heredoc
        include Writer, Adamantium

        def emit_heredoc_header
          write('<<-HEREDOC')
        end

        def emit_heredoc_remainder
          emit_heredoc_body
          emit_heredoc_footer
        end

      private

        def emit_heredoc_body
          nl
          emit_normal_heredoc_body
        end

        def emit_heredoc_footer
          write('HEREDOC')
        end

        def emit_normal_heredoc_body
          buffer.root_indent do
            children.each do |child|
              if n_str?(child)
                write(escape_dynamic(child.children.first))
              else
                emit_dynamic(child)
              end
            end
          end
        end

        def escape_dynamic(string)
          string.gsub('#', '\#')
        end

        def emit_dynamic(child)
          if FLAT_INTERPOLATION.include?(child.type)
            write('#')
            visit(child)
          else
            write('#{')
            emit_dynamic_component(child.children.first)
            write('}')
          end
        end

        def emit_dynamic_component(node)
          visit(node) if node
        end
      end

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

        def dstr_boundary?(segment, child)
          child.type.equal?(:dstr) || segment.last&.type.equal?(:dstr)
        end

        def str_nl?(node)
          node.type.equal?(:str) && node.children.first.end_with?("\n")
        end

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
            when *FLAT_INTERPOLATION
              write('#')
              visit(child)
            when :str
              string = child.children.first

              next_child = children[index.succ]

              if string.end_with?("\n") && next_child && next_child.type.equal?(:str)
                write(escape_delim(string))
              else
                write(child.children.first.inspect[1..-2])
              end
            when :dstr
              emit_segment_body(child.children)
            else
              fail "Unknown dstr member: #{child.type}"
            end
          end
        end

        def escape_delim(string)
          string.gsub('"', '\\"')
        end
      end

    private

      def heredoc?
        if children.length >= HEREDOC_THRESHOLD
          round_trips_heredoc?
        else
          round_tripping_segmented_source.nil? && round_trips_heredoc?
        end
      end
      memoize :heredoc?

      def round_trips_heredoc?
        round_trips?(source: heredoc_source)
      end
      memoize :round_trips_heredoc?

      def round_tripping_segmented_source
        candidates = 0
        each_segments(children) do |segments|
          candidates +=1
          puts "Candidates tested: #{candidates}" if (candidates % 100).zero?

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
          buffer:               buffer,
          comments:             comments,
          local_variable_scope: local_variable_scope,
          node:                 node,
          segments:             segments
        ).dispatch

        buffer.content.freeze
      end

      def heredoc_writer
        writer_with(Heredoc, node:)
      end
      memoize :heredoc_writer

      def heredoc_source
        buffer = Buffer.new

        writer = Heredoc.new(
          buffer:               buffer,
          comments:             comments,
          local_variable_scope: local_variable_scope,
          node:                 node
        )

        writer.emit_heredoc_header
        writer.emit_heredoc_remainder

        buffer.content.freeze
      end
      memoize :heredoc_source
    end # DynamicString
  end # Writer
end # Unparser
