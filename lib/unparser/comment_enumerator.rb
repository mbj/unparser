module Unparser
  class CommentEnumerator
    def initialize(comments)
      @comments = comments
      @index = 0
    end

    def take_while
      start_index = @index
      while @index < @comments.size
        bool = yield @comments[@index]
        break unless bool
        @index += 1
      end
      @comments[start_index...@index]
    end

    def take_before(position)
      take_while { |comment| comment.location.expression.end_pos <= position }
    end

    def take_up_to_line(line)
      take_while { |comment| comment.location.expression.line <= line }
    end

    def take_all_contiguous_after(position)
      take_while do |comment|
        comment_range = comment.location.expression
        range_between = Parser::Source::Range.new(comment_range.source_buffer, position, comment_range.begin_pos)
        if range_between.source =~ /\A\s*\Z/
          position = comment_range.end_pos
          true
        end
      end
    end
  end
end