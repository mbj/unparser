# frozen_string_literal: true

module Unparser
  # Validation of unparser results
  class Validation
    include Adamantium, Anima.new(
      :generated_node,
      :generated_source,
      :identification,
      :original_ast,
      :original_source
    )

    class PhaseException
      include Anima.new(:exception, :phase)
    end

    # Test if source could be unparsed successfully
    #
    # @return [Boolean]
    #
    # @api private
    #
    # rubocop:disable Style/OperatorMethodCall
    # mutant:disable
    def success?
      [
        original_source,
        original_ast,
        generated_source,
        generated_node
      ].all?(&:right?) && generated_node.from_right.==(original_node.from_right)
    end
    # rubocop:enable Style/OperatorMethodCall

    # Return error report
    #
    # @return [String]
    #
    # @api private
    # mutant:disable
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

    # mutant:disable
    def original_node
      original_ast.fmap(&:node)
    end

    # Create validator from string
    #
    # @param [String] original_source
    #
    # @return [Validator]
    # mutant:disable
    def self.from_string(original_source)
      original_ast = parse_ast_either(original_source)

      generated_source = original_ast
        .lmap(&method(:const_unit))
        .bind(&method(:unparse_ast_either))

      generated_node = generated_source
        .lmap(&method(:const_unit))
        .bind(&method(:parse_ast_either))
        .fmap(&:node)

      new(
        generated_node:   generated_node,
        generated_source: generated_source,
        identification:   '(string)',
        original_ast:     original_ast,
        original_source:  Either::Right.new(original_source)
      )
    end

    # Create validator from ast
    #
    # @param [Unparser::AST] ast
    #
    # @return [Validator]
    #
    # mutant:disable
    def self.from_ast(ast:)
      generated_source = Unparser.unparse_ast_either(ast)

      generated_node = generated_source
        .lmap(&method(:const_unit))
        .bind(&method(:parse_ast_either))
        .fmap(&:node)

      new(
        identification:   '(string)',
        original_source:  generated_source,
        original_ast:     Either::Right.new(ast),
        generated_source: generated_source,
        generated_node:   generated_node
      )
    end

    # Create validator from file
    #
    # @param [Pathname] path
    #
    # @return [Validator]
    #
    # mutant:disable
    def self.from_path(path)
      from_string(path.read.freeze).with(identification: path.to_s)
    end

    # mutant:disable
    def self.unparse_ast_either(ast)
      Unparser.unparse_ast_either(ast)
    end
    private_class_method :unparse_ast_either

    # mutant:disable
    def self.parse_ast_either(source)
      Unparser.parse_ast_either(source)
    end
    private_class_method :parse_ast_either

    # mutant:disable
    def self.const_unit(_); end
    private_class_method :const_unit

  private

    # mutant:disable
    def make_report(label, attribute_name)
      ["#{label}:"].concat(public_send(attribute_name).either(method(:report_exception), ->(value) { [value] }))
    end

    # mutant:disable
    def report_exception(phase_exception)
      if phase_exception
        [phase_exception.inspect].concat(phase_exception.backtrace.take(20))
      else
        %w[undefined]
      end
    end

    # mutant:disable
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

    class Literal < self
      # mutant:disable
      def success?
        original_source.eql?(generated_source)
      end

      # mutant:disable
      def report
        message = [identification]

        message.concat(make_report('Original-Source',  :original_source))
        message.concat(make_report('Generated-Source', :generated_source))
        message.concat(make_report('Original-Node',    :original_node))
        message.concat(make_report('Generated-Node',   :generated_node))
        message.concat(node_diff_report)
        message.concat(source_diff_report)

        message.join("\n")
      end

    private

      # mutant:disable
      def source_diff_report
        diff = nil

        original_source.fmap do |original|
          generated_source.fmap do |generated|
            diff = Diff.new(
              encode(original).split("\n", -1),
              encode(generated).split("\n", -1)
            ).colorized_diff
          end
        end

        diff ? ['Source-Diff:', diff] : []
      end

      # mutant:disable
      def encode(string)
        string.encode('UTF-8', invalid: :replace, undef: :replace)
      end
    end # Literal
  end # Validation
end # Unparser
