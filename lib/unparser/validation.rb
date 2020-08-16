# frozen_string_literal: true

module Unparser
  # Validation of unparser results
  #
  # ignore :reek:TooManyMethods
  class Validation
    include Adamantium::Flat, Anima.new(
      :generated_node,
      :generated_source,
      :identification,
      :original_node,
      :original_source
    )

    # Test if source could be unparsed successfully
    #
    # @return [Boolean]
    #
    # @api private
    #
    def success?
      [
        original_source,
        original_node,
        generated_source,
        generated_node
      ].all?(&:right?) && generated_node.from_right.eql?(original_node.from_right)
    end

    # Return error report
    #
    # @return [String]
    #
    # @api private
    #
    def report
      message = [identification]

      message.concat(make_report('Original-Source',  :original_source))
      message.concat(make_report('Generated-Source', :generated_source))
      message.concat(make_report('Original-Node',    :original_node))
      message.concat(make_report('Generated-Node',   :generated_node))
      message.concat(node_diff_report)

      message.join("\n")
    end
    memoize :report

    # Create validator from string
    #
    # @param [String] original_source
    #
    # @return [Validator]
    def self.from_string(original_source)
      original_node = Unparser
        .parse_either(original_source)
        .fmap(&Preprocessor.method(:run))

      generated_source = original_node
        .lmap(&method(:const_unit))
        .bind(&method(:unparse_either))

      generated_node = generated_source
        .lmap(&method(:const_unit))
        .bind(&Unparser.method(:parse_either))
        .fmap(&Preprocessor.method(:run))

      new(
        identification:   '(string)',
        original_source:  MPrelude::Either::Right.new(original_source),
        original_node:    original_node,
        generated_source: generated_source,
        generated_node:   generated_node
      )
    end

    # Create validator from file
    #
    # @param [Pathname] path
    #
    # @return [Validator]
    def self.from_path(path)
      from_string(path.read).with(identification: path.to_s)
    end

  private

    # Create a labeled report from
    #
    # @param [String] label
    # @param [Symbol] attribute_name
    #
    # @return [Array<String>]
    def make_report(label, attribute_name)
      ["#{label}:"].concat(public_send(attribute_name).either(method(:report_exception), ->(value) { [value] }))
    end

    # Report optional exception
    #
    # @param [Exception, nil] exception
    #
    # @return [Array<String>]
    def report_exception(exception)
      if exception
        [exception.inspect].concat(exception.backtrace.take(20))
      else
        ['undefined']
      end
    end

    # Report the node diff
    #
    # @return [Array<String>]
    def node_diff_report
      diff = nil

      original_node.fmap do |original|
        generated_node.fmap do |generated|
          diff = Diff.new(
            original.to_s.lines.map(&:chomp),
            generated.to_s.lines.map(&:chomp)
          ).colorized_diff
        end
      end

      diff ? ['Node-Diff:', diff] : []
    end

    # Create unit represented as nil
    #
    # @param [Object] _value
    #
    # @return [nil]
    def self.const_unit(_value); end
    private_class_method :const_unit

    # Unparse capturing errors
    #
    # @param [Parser::AST::Node] node
    #
    # @return [Either<RuntimeError, String>]
    def self.unparse_either(node)
      MPrelude::Either
        .wrap_error(RuntimeError) { Unparser.unparse(node) }
    end
    private_class_method :unparse_either
  end # Validation
end # Unparser
