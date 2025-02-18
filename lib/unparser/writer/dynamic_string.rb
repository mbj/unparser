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
      HEREDOC_HEADER    = "<<-#{HEREDOC_DELIMITER}"
      HEREDOC_FOOTER    = "#{HEREDOC_DELIMITER}\n"

      private_constant(*constants(false))

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
          buffer:,
          comments:,
          explicit_encoding:,
          local_variable_scope:,
          node:,
          segments:
        ).dispatch

        buffer.content.freeze
      end

      def heredoc_writer
        writer_with(Heredoc, node:)
      end
      memoize :heredoc_writer

      def heredoc_body
        buffer = Buffer.new

        writer = Heredoc.new(
          buffer:,
          comments:,
          explicit_encoding:,
          local_variable_scope:,
          node:
        )

        writer.emit

        buffer.content.freeze
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
    end # DynamicString
  end # Writer
end # Unparser
