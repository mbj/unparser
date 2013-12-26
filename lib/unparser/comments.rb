module Unparser

  # Holds the comments that remain to be emitted
  class Comments

    # Initialize object
    #
    # @param [Array] comments
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(comments)
      @comments = comments.dup
      @last_range_consumed = nil
    end

    # Consume part or all of the node
    #
    # @param [Parser::AST::Node] node
    # @param [Symbol] source_part
    #
    # @return [undefined]
    #
    # @api private
    #
    def consume(node, source_part = :expression)
      location = node.location
      return unless location
      @last_range_consumed = location.public_send(source_part)
    end

    # Take end-of-line comments
    #
    # @return [Array]
    #
    # @api private
    #
    def take_eol_comments
      return EMPTY_ARRAY unless @last_range_consumed
      comments = take_up_to_line(@last_range_consumed.end.line)
      unshift_documents(comments)
    end

    # Take all remaining comments
    #
    # @return [Array]
    #
    # @api private
    #
    def take_all
      take_while { true }
    end

    # Take comments appear in the source before the specified part of the node
    #
    # @param [Parser::AST::Node] node
    # @param [Symbol] source_part
    #
    # @return [Array]
    #
    # @api private
    #
    def take_before(node, source_part)
      location = node.location
      if location.respond_to?(source_part)
        range = location.public_send(source_part)
        take_while { |comment| comment.location.expression.end_pos <= range.begin_pos }
      else
        EMPTY_ARRAY
      end
    end

  private

    # Take comments while the provided block returns true
    #
    # @yield [Parser::Source::Comment]
    #
    # @return [Array]
    #
    # @api private
    #
    def take_while
      number_to_take = @comments.index { |comment| !yield(comment) } || @comments.size
      @comments.shift(number_to_take)
    end

    # Take comments up to the line number
    #
    # @param [Fixnum] line
    #
    # @return [Array]
    #
    # @api private
    #
    def take_up_to_line(line)
      take_while { |comment| comment.location.expression.line <= line }
    end

    # Unshift document comments and return the rest
    #
    # @param [Array] comments
    #
    # @return [Array]
    #
    # @api private
    #
    def unshift_documents(comments)
      doc_comments, other_comments = comments.partition(&:document?)
      doc_comments.reverse_each { |comment| @comments.unshift(comment) }
      other_comments
    end

  end # Comments
end # Unparser
