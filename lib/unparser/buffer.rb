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
      @line_suffix = ''
      @suffix_lines = []
      @indent = 0
    end

    class SuffixLine < Struct.new(:indented, :string)
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

    def fresh_line?
      @content.empty? || @content[-1] == NL
    end

    def append_to_end_of_line(string)
      @line_suffix << string
      self
    end

    def append_suffix_line(indented, string)
      @suffix_lines << SuffixLine.new(indented, string)
      self
    end

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
      @indent+=1
      nl
      self
    end

    # Decrease indent
    #
    # @return [self]
    #
    # @api private
    #
    def unindent
      nl
      @indent-=1
      self
    end

    # Write newline
    #
    # @return [self]
    #
    # @api private
    #
    def nl
      suffix
      @content << NL
      self
    end

    # Return content of buffer
    #
    # @return [String]
    #
    # @api private
    #
    def content
      suffix
      @content.dup.freeze
    end

  private

    # Write prefix
    #
    # @return [String]
    #
    # @api private
    #
    def prefix
      @content << '  '*@indent
    end

    def suffix
      @content << @line_suffix
      @line_suffix = ''
      @suffix_lines.each do |suffix_line|
        @content << NL
        if suffix_line.indented
          append(suffix_line.string)
        else
          append_without_prefix(suffix_line.string)
        end
      end
      @suffix_lines.clear
    end

  end # Buffer
end # Unparser
