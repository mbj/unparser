# encoding: utf-8

module Unparser

  # Buffer used to emit into
  class Buffer

    NL = "\n".freeze

    # Initialize object
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize
      @content = ''
      @indent = 0
    end

    # Append string
    #
    # @param [String] string
    #
    # @return [self]
    #
    # @api private
    #
    def append(string)
      if @content[-1] == NL
        prefix
      end
      @content << string
      self
    end

    # Append a string without an indentation prefix
    #
    # @param [String] string
    #
    # @return [self]
    #
    # @api private
    #
    def append_without_prefix(string)
      @content << string
      self
    end

    # Increase indent
    #
    # @return [self]
    #
    # @api private
    #
    def indent
      @indent += 1
      self
    end

    # Decrease indent
    #
    # @return [self]
    #
    # @api private
    #
    def unindent
      @indent -= 1
      self
    end

    # Write newline
    #
    # @return [self]
    #
    # @api private
    #
    def nl
      @content << NL
      self
    end

    # Test for a fresh line
    #
    # @return [true]
    #   if the buffer content ends with a fresh line
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    def fresh_line?
      @content.empty? || @content[-1] == NL
    end

    # Return content of buffer
    #
    # @return [String]
    #
    # @api private
    #
    def content
      @content.dup.freeze
    end

    # Capture the content written to the buffer within the block
    #
    # @return [String]
    #
    # @api private
    #
    def capture_content
      size_before = @content.size
      yield
      @content[size_before..-1]
    end

  private

    INDENT_SPACE = '  '.freeze

    # Write prefix
    #
    # @return [String]
    #
    # @api private
    #
    def prefix
      @content << INDENT_SPACE * @indent
    end

  end # Buffer
end # Unparser
