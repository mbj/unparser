module Unparser

  # Buffer used to emit into
  class Buffer

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
      prefix
      @content << string
      self
    end

    # Write newline
    #
    # @return [self]
    #
    # @api private
    #
    def nl
      @content << "\n"
      self
    end

    # Write prefix
    #
    # @return [String]
    #
    # @api private
    #
    def prefix
      @content << "  "*@indent
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
      self
    end

    # Decrease indent
    #
    # @return [self]
    #
    # @api private
    #
    def unindent
      @indent-=1
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

  end # Buffer
end # Unparser
