require 'unparser'
require 'mutant'
require 'optparse'

require 'unparser/cli/preprocessor'
require 'unparser/cli/source'
require 'unparser/cli/differ'

module Unparser
  # Unparser CLI implementation
  class CLI

    EXIT_SUCCESS = 0
    EXIT_FAILURE = 1

    # Run CLI
    #
    # @param [Array<String>] arguments
    #
    # @return [Fixnum]
    #   the exit status
    #
    # @api private
    #
    def self.run(*arguments)
      new(*arguments).exit_status
    end

    # Initialize object
    #
    # @param [Array<String>] arguments
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(arguments)
      @sources = []

      @success   = true
      @fail_fast = false

      opts = OptionParser.new do |builder|
        add_options(builder)
      end

      file_names = opts.parse!(arguments)

      file_names.each do |file_name|
        @sources << Source::File.new(file_name)
      end
    end

    # Add options
    #
    # @param [Optparse::Builder] builder
    #
    # @return [undefined]
    #
    # @api private
    #
    def add_options(builder)
      builder.banner = 'usage: unparse [options] FILE [FILE]'
      builder.separator('')
      builder.on('-e', '--evaluate SOURCE') do |original_source|
        @sources << Source::String.new(original_source)
      end
      builder.on('--fail-fast') do
        @fail_fast = true
      end
    end

    # Return exit status
    #
    # @return [Fixnum]
    #
    # @api private
    #
    def exit_status
      @sources.each do |source|
        process_source(source)
        if @fail_fast
          break unless @success
        end
      end

      @success ? EXIT_SUCCESS : EXIT_FAILURE
    end

  private

    # Process source
    #
    # @param [CLI::Source]
    #
    # @return [undefined]
    #
    # @api private
    #
    def process_source(source)
      if source.success?
        puts "Success: #{source.identification}"
      else
        puts source.error_report
        puts "Error: #{source.identification}"
        @success = false
      end
    end

  end # CLI
end # Unparser
