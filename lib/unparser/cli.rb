require 'unparser'
require 'mutant'
require 'optparse'

require 'unparser/cli/preprocessor'
require 'unparser/cli/source'

module Unparser
  # Unparser CLI implementation
  class CLI

    # Unparser CLI specific differ
    class Differ < Mutant::Differ

      def self.run(*arguments)
        new(*arguments).colorized_diff
      end

      # Return source diff
      #
      # @return [String]
      #   if there is a diff
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def diff
        diffs.map do |piece|
          Diff::LCS::Hunk.new(old, new, piece, max_length, old.length - new.length).diff(:unified) << "\n"
        end.join
      end
      memoize :diff

    end # Differ

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

      opts = OptionParser.new do |builder|
        add_options(builder)
      end

      file_names =
        begin
          opts.parse!(arguments)
        rescue OptionParser::ParseError => error
          raise(Error, error.message, error.backtrace)
        end

      file_names.each do |file_name|
        @sources << Source::File.new(file_name)
      end

      @exit_success = true
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
      builder.separator('').on('-e', '--evaluate SOURCE') do |original_source|
        @sources << Source::String.new(original_source)
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
      end
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
        @exit_success = false
      end
    end
  end # CLI
end # Unparser
