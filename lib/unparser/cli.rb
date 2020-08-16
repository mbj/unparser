# frozen_string_literal: true

require 'unparser'
require 'optparse'

module Unparser
  # Unparser CLI implementation
  #
  # :reek:InstanceVariableAssumption
  # :reek:TooManyInstanceVariables
  class CLI

    EXIT_SUCCESS = 0
    EXIT_FAILURE = 1

    class Target
      include AbstractType

      # Path target
      class Path < self
        include Concord.new(:path)

        # Validation for this target
        #
        # @return [Validation]
        def validation
          Validation.from_path(path)
        end
      end

      # String target
      class String
        include Concord.new(:string)

        # Validation for this target
        #
        # @return [Validation]
        def validation
          Validation.from_string(string)
        end
      end # String
    end # Target

    private_constant(*constants(false))

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
    # ignore :reek:TooManyStatements
    def initialize(arguments)
      @ignore  = Set.new
      @targets = []

      @success   = true
      @fail_fast = false
      @verbose   = false

      opts = OptionParser.new do |builder|
        add_options(builder)
      end

      opts.parse!(arguments).each do |name|
        @targets.concat(targets(name))
      end
    end

    # Add options
    #
    # @param [OptionParser] builder
    #
    # @return [undefined]
    #
    # @api private
    #
    # ignore :reek:TooManyStatements
    def add_options(builder)
      builder.banner = 'usage: unparse [options] FILE [FILE]'
      builder.separator('')
      builder.on('-e', '--evaluate SOURCE') do |source|
        @targets << Target::String.new(source)
      end
      builder.on('--start-with FILE') do |path|
        @start_with = targets(path).first
      end
      builder.on('-v', '--verbose') do
        @verbose = true
      end
      builder.on('--ignore FILE') do |file|
        @ignore.merge(targets(file))
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
      effective_targets.each do |target|
        process_target(target)
        break if @fail_fast && !@success
      end

      @success ? EXIT_SUCCESS : EXIT_FAILURE
    end

  private

    # Process target
    #
    # @param [Target] target
    #
    # @return [undefined]
    #
    # @api private
    #
    def process_target(target)
      validation = target.validation
      if validation.success?
        puts validation.report if @verbose
        puts "Success: #{validation.identification}"
      else
        puts validation.report
        puts "Error: #{validation.identification}"
        @success = false
      end
    end

    # Return effective targets
    #
    # @return [Enumerable<Target>]
    #
    # @api private
    #
    def effective_targets
      if @start_with
        reject = true
        @targets.reject do |targets|
          if reject && targets.eql?(@start_with)
            reject = false
          end

          reject
        end
      else
        @targets
      end.reject(&@ignore.method(:include?))
    end

    # Return targets for file name
    #
    # @param [String] file_name
    #
    # @return [Enumerable<Target>]
    #
    # @api private
    #
    # ignore :reek:UtilityFunction
    def targets(file_name)
      if File.directory?(file_name)
        Dir.glob(File.join(file_name, '**/*.rb')).sort
      elsif File.file?(file_name)
        [file_name]
      else
        Dir.glob(file_name).sort
      end.map { |file| Target::Path.new(Pathname.new(file)) }
    end

  end # CLI
end # Unparser
