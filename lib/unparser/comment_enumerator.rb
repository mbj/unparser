module Unparser
  class CommentEnumerator
    def initialize(comments)
      @comments = comments.dup
    end

    attr_writer :last_source_range_written

    def take_eol_comments
      return [] if @last_source_range_written.nil?
      comments = take_up_to_line @last_source_range_written.end.line
      doc_comments, eol_comments = comments.partition(&:document?)
      doc_comments.reverse.each {|comment| @comments.unshift comment }
      eol_comments
    end

    def take_all
      take_while { true }
    end

    def take_before(position)
      take_while { |comment| comment.location.expression.end_pos <= position }
    end

  private

    def take_while
      number_to_take = @comments.index {|comment| !yield(comment) } || @comments.size
      @comments.shift(number_to_take)
    end

    def take_up_to_line(line)
      take_while { |comment| comment.location.expression.line <= line }
    end
  end
end