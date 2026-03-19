# frozen_string_literal: true

module Unparser
  # Define equality, equivalence and inspection methods
  #
  # Original code before vendoring and reduction from: https://github.com/dkubb/equalizer.
  module Equalizer
    # Creates a module providing equality methods based on the given attributes
    #
    # @param keys [Array<Symbol>] attribute names to use for equality
    # @param inspect [Boolean] whether to override #inspect and #pretty_print
    # @return [Module] a module to include in your class
    # @raise [ArgumentError] if keys is empty or contains non-Symbols
    #
    # @api public
    def self.new(*keys, inspect: true)
      build_module(keys.freeze, inspect:)
    end

    # Instance methods mixed into classes that include an Equalizer module
    #
    # @api private
    module InstanceMethods
      # Equality comparison allowing subclasses
      #
      # @param other [Object] object to compare
      # @return [Boolean] true if other is_a? same class with equal attributes
      def ==(other)
        other.is_a?(self.class) &&
          cmp?(:==, other)
      end

      # Strict equality requiring exact class match
      #
      # @param other [Object] object to compare
      # @return [Boolean] true if other is exact same class with eql? attributes
      def eql?(other)
        other.instance_of?(self.class) &&
          cmp?(:eql?, other)
      end

      # Hash code based on class and attribute values
      #
      # @return [Integer] hash code
      def hash
        [self.class, *deconstruct].hash
      end

      # Array deconstruction for pattern matching
      #
      # @return [Array] attribute values in order
      def deconstruct
        equalizer_keys.map { |key| public_send(key) }
      end

      # Hash deconstruction for pattern matching
      #
      # @param requested [Array<Symbol>, nil] keys to include, or nil for all
      # @return [Hash{Symbol => Object}] requested attribute key-value pairs
      def deconstruct_keys(requested)
        subset = requested.nil? ? equalizer_keys : equalizer_keys & requested
        subset.to_h { |key| [key, public_send(key)] }
      end

      private

      # Compare all attributes using the given comparator
      #
      # @param comparator [Symbol] method to use for comparison
      # @param other [Object] object to compare against
      # @return [Boolean] true if all attributes match
      #
      # @api private
      def cmp?(comparator, other)
        equalizer_keys.all? do |key|
          public_send(key)
            .public_send(comparator, other.public_send(key))
        end
      end
    end

    # Instance methods for inspect and pretty print output
    #
    # @api private
    module InspectMethods
      # String representation showing only equalizer attributes
      #
      # @return [String] inspect output
      def inspect
        attrs = equalizer_keys
          .map { |key| "@#{key}=#{public_send(key).inspect}" }
          .join(', ')
        Object.instance_method(:to_s).bind_call(self).sub(/>\z/, " #{attrs}>")
      end

      # Pretty print output using PP's object formatting
      #
      # @param q [PP] pretty printer
      # @return [void]
      def pretty_print(pretty_printer)
        pretty_printer.pp_object(self)
      end

      # Instance variables to display in pretty print output
      #
      # @return [Array<Symbol>] instance variable names
      def pretty_print_instance_variables
        equalizer_keys.map { |key| :"@#{key}" }
      end
    end

    # Builds the module with equality methods for the given keys
    #
    # @param keys [Array<Symbol>] attribute names (frozen)
    # @param inspect [Boolean] whether to include inspect methods
    # @return [Module] the configured module
    #
    # @api private
    def self.build_module(keys, inspect:)
      Module.new do
        include InstanceMethods
        include InspectMethods if inspect

        set_temporary_name("Equalizer(#{keys.join(', ')})")

        define_method(:equalizer_keys) { keys }
        private :equalizer_keys
      end
    end
    private_class_method :build_module
  end # module Equalizer
end # Unparser
