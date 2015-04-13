# encoding: utf-8

module Unparser

  # Holds the comments that remain to be emitted
  class Comments

    # Proxy to singleton
    #
    # NOTICE:
    #   Delegating to stateless helpers is a pattern I saw many times in our code.
    #   Maybe we should make another helper module? include SingletonDelegator.new(:source_range) ?
    #
    # @return [undefined]
    #
    # @api private
    #
    def source_range(*arguments)
      self.class.source_range(*arguments)
    end

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
      range = source_range(node, source_part)
      @last_range_consumed = range if range
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
      range = source_range(node, source_part)
      if range
        take_while { |comment| comment.location.expression.end_pos <= range.begin_pos }
      else
        EMPTY_ARRAY
      end
    end

    # Return source location part
    #
    # FIXME: This method should not be needed. It does to much inline signalling.
    #
    # @param [Parser::AST::Node] node
    # @param [Symbol] part
    #
    # @return [Parser::Source::Range]
    #   if present
    #
    # @return [nil]
    #   otherwise
    #
    # @api private
    #
    def self.source_range(node, part)
      has_part = node.respond_to?(:location) && node.location.respond_to?(part)
      node.location.public_send(part) if has_part
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
