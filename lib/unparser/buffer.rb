# frozen_string_literal: true

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
      @content  = +''
      @heredocs = []
      @indent   = 0
      @no_nl    = true
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
      if @content[-1].eql?(NL)
        prefix
      end
      write(string)
      self
    end

    # Push to heredoc stack
    #
    # @param [String] heredoc
    def push_heredoc(heredoc)
      @heredocs << heredoc
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
      write(string)
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

    def ensure_nl
      nl unless fresh_line?
    end

    # Write newline
    #
    # @return [self]
    #
    # @api private
    #
    def nl
      @no_nl = false
      write(NL)
      flush_heredocs
      self
    end

    # Write final newline
    def final_newline
      return if fresh_line? || @no_nl

      write(NL)
    end

    def nl_flush_heredocs
      return if @heredocs.empty?

      if fresh_line?
        flush_heredocs
      else
        nl
      end
    end

    def root_indent
      before = @indent
      @indent = 0
      yield
      @indent = before
    end

    # Test for a fresh line
    #
    # @return [Boolean]
    #
    # @api private
    #
    def fresh_line?
      @content.empty? || @content[-1].eql?(NL)
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

    # Write raw fragment to buffer
    #
    # Does not do indentation logic.
    #
    # @param [String] fragment
    #
    # @return [self]
    def write(fragment)
      @content << fragment
      self
    end

    def write_encoding(encoding)
      write("# -*- encoding: #{encoding} -*-\n")
    end

  private

    INDENT_SPACE = '  '.freeze

    def prefix
      write(INDENT_SPACE * @indent)
    end

    def flush_heredocs
      @heredocs.each(&public_method(:write))
      @heredocs = []
    end

  end # Buffer
end # Unparser
