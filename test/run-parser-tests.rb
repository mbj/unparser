require 'anima'
require 'unparser'

$: << __dir__

testBuilder = Class.new(Parser::Builders::Default)
testBuilder.modernize

MODERN_ATTRIBUTES = testBuilder.instance_variables.map do |instance_variable|
  attribute_name = instance_variable.to_s[1..-1].to_sym
  [attribute_name, testBuilder.public_send(attribute_name)]
end.to_h

def default_builder_attributes
  MODERN_ATTRIBUTES.keys.map do |attribute_name|
    [attribute_name, Parser::Builders::Default.public_send(attribute_name)]
  end.to_h
end

class Test
  include Adamantium, Anima.new(
    :default_builder_attributes,
    :group_index,
    :name,
    :node,
    :parser_source,
    :rubies
  )

  TARGET_RUBIES = %w[2.5 2.6 2.7]

  EXPECT_FAILURE = {}.freeze

  def legacy_attributes
    default_builder_attributes.select do |attribute_name, value|
      !MODERN_ATTRIBUTES.fetch(attribute_name).equal?(value)
    end.to_h
  end
  memoize :legacy_attributes

  def skip_reason
    if !legacy_attributes.empty?
      "Legacy parser attributes: #{legacy_attributes}"
    elsif !allow_ruby?
      "Non targeted rubies: #{rubies.join(',')}"
    elsif validation.original_node.left?
      "Test specifies a syntax error"
    end
  end

  def success?
    validation.success?
  end

  def expect_failure?
    EXPECT_FAILURE.key?([name, group_index])
  end

  def allow_ruby?
    rubies.empty? || rubies.any?(TARGET_RUBIES.method(:include?))
  end

  def right(value)
    Unparser::Either::Right.new(value)
  end

  def validation
    identification   = name.to_s
    generated_source = Unparser.unparse_either(node)

    generated_node = generated_source.lmap{ |_value| }.bind do |source|
      parse_either(source, identification)
    end

    Unparser::Validation.new(
      generated_node:   generated_node,
      generated_source: generated_source,
      identification:   identification,
      original_node:    parse_either(parser_source, identification).fmap { node },
      original_source:  right(parser_source)
    )
  end
  memoize :validation

  def parser
    Unparser.parser.tap do |parser|
      %w(foo bar baz).each(&parser.static_env.method(:declare))
    end
  end

  def parse_either(source, identification)
    Unparser::Either.wrap_error(Parser::SyntaxError) do
      parser.parse(Unparser.buffer(source, identification))
    end
  end
end

class Execution
  include Anima.new(:number, :total, :test)

  def call
    skip_reason = test.skip_reason
    if skip_reason
      print('Skip', skip_reason)
      return
    end

    if test.expect_failure?
      expect_failure
    else
      expect_success
    end
  end

private

  def expect_failure
    if test.success?
      fail format('Expected Failure', 'but got success')
    else
      print('Expected Failure')
    end
  end

  def expect_success
    if test.success?
      print('Success')
    else
      puts(test.validation.report)
      fail format('Failure')
    end
  end

  def format(status, message = '')
    '%3d/%3d: %-16s %s[%02d] %s' % [number, total, status, test.name, test.group_index, message]
  end

  def print(status, message = '')
    puts(format(status, message))
  end
end

module Minitest
  class Test
  end # Test
end # Minitest

class Extractor
  class Capture
    include Anima.new(
      :default_builder_attributes,
      :node,
      :parser_source,
      :rubies
    )

  end

  attr_reader :tests

  def initialize
    @captures = []
    @tests    = []
  end

  def capture(**attributes)
    @captures << Capture.new(attributes)
  end

  def reset
    @captures = []
  end

  def call(name)
    reset

    TestParser.new.send(name)

    @captures.each_with_index do |capture, index|
      @tests << Test.new(name: name, group_index: index, **capture.to_h)
    end

    reset
  end
end

require '../parser/test/parse_helper.rb'
require '../parser/test/test_parser.rb'

EXTRACTOR = Extractor.new

module ParseHelper
  def assert_diagnoses(*arguments)
  end

  def s(type, *children)
    Parser::AST::Node.new(type, children)
  end

  def assert_parses(node, parser_source, _diagnostics = nil, rubies = [])
    EXTRACTOR.capture(
      default_builder_attributes: default_builder_attributes,
      node:                       node,
      parser_source:              parser_source,
      rubies:                     rubies
    )
  end

  def test_clrf_line_endings(*arguments)
  end

  def with_versions(*arguments)
  end

  def assert_context(*arguments)
  end

  def refute_diagnoses(*arguments)
  end

  def assert_diagnoses_many(*arguments)
  end
end

TestParser.instance_methods.grep(/\Atest_/).each(&EXTRACTOR.method(:call))

EXTRACTOR.tests.sort_by(&:name).each_with_index do |test, index|
  Execution.new(number: index.succ, total:  EXTRACTOR.tests.length, test: test).call
end
