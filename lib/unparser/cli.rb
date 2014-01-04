# encoding: utf-8

require 'unparser'
require 'optparse'
require 'diff/lcs'
require 'diff/lcs/hunk'

require 'unparser/cli/preprocessor'
require 'unparser/cli/source'
require 'unparser/cli/differ'
require 'unparser/cli/color'

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
      @sources, @ignore = [], []

      @success   = true
      @fail_fast = false

      opts = OptionParser.new do |builder|
        add_options(builder)
      end

      opts.parse!(arguments).each do |name|
        if File.directory?(name)
          add_directory(name)
        else
          add_file(name)
        end
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
      builder.on('--skip-until FILE') do |file|
        @skip_until = file
      end
      builder.on('--ignore FILE') do |file|
        @ignore << file
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

    # Add file
    #
    # @param [String] file_name
    #
    # @return [undefined]
    #
    # @api private
    #
    def add_file(file_name)
      if @skip_until
        if @skip_until == file_name
          @skip_until = nil
        else
          return
        end
      end
      unless @ignore.include?(file_name)
        @sources << Source::File.new(file_name)
      end
    end

    # Add directory
    #
    # @param [String] directory_name
    #
    # @return [undefined]
    #
    # @api private
    #
    def add_directory(directory_name)
      Dir.glob(File.join(directory_name, '**/*.rb')).each do |file_name|
        add_file(file_name)
      end
    end

  end # CLI
end # Unparser
