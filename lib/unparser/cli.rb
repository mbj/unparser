require 'unparser'
require 'optparse'
require 'diff/lcs'
require 'diff/lcs/hunk'

require 'unparser/cli/source'
require 'unparser/cli/differ'
require 'unparser/cli/color'

module Unparser
  # Unparser CLI implementation
  #
  # :reek:InstanceVariableAssumption
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
      @ignore = Set.new

      @success   = true
      @fail_fast = false
      @verbose   = false

      opts = OptionParser.new do |builder|
        add_options(builder)
      end

      opts.parse!(arguments).each do |name|
        @sources.concat(sources(name))
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
      builder.on('-e', '--evaluate SOURCE') do |source|
        @sources << Source::String.new(source)
      end
      builder.on('--start-with FILE') do |file|
        @start_with = sources(file).first
      end
      builder.on('-v', '--verbose') do
        @verbose = true
      end
      builder.on('--ignore FILE') do |file|
        @ignore.merge(sources(file))
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
      effective_sources.each do |source|
        next if @ignore.include?(source)
        process_source(source)
        break if @fail_fast && !@success
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
        puts source.report if @verbose
        puts "Success: #{source.identification}"
      else
        puts source.report
        puts "Error: #{source.identification}"
        @success = false
      end
    end

    # Return effective sources
    #
    # @return [Enumerable<CLI::Source>]
    #
    # @api private
    #
    def effective_sources
      if @start_with
        reject = true
        @sources.reject do |source|
          if reject && source.eql?(@start_with)
            reject = false
          end

          reject
        end
      else
        @sources
      end
    end

    # Return sources for file name
    #
    # @param [String] file_name
    #
    # @return [Enumerable<CLI::Source>]
    #
    # @api private
    #
    def sources(file_name)
      files =
        if File.directory?(file_name)
          Dir.glob(File.join(file_name, '**/*.rb')).sort
        elsif File.file?(file_name)
          [file_name]
        else
          Dir.glob(file_name).sort
        end

      files.map(&Source::File.method(:new))
    end

  end # CLI
end # Unparser
