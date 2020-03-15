require 'unparser'
require 'unparser/cli'

$: << __dir__

module ParseHelper
  include Unparser::NodeHelpers

  ALL_VERSIONS = []

  def assert_diagnoses(*arguments)
  end

  def assert_parses(node, source, _diagnostics = nil, _rubies = nil)
    Extractor.node(node, source)
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

class Test
  include Adamantium::Flat, Concord::Public.new(:name, :node, :parser_source)

  def success?
    source.success?
  end

  SKIP = %i[
    test_dedenting_heredoc
    test_regex_interp
    test_return_in_class
    test_bug_480
  ]

  def run
    if SKIP.include?(name)
      puts "Skipping: #{name}"
    else
      puts "Running: #{name}"
      unless source.success?
        puts source.report
        fail
      end
    end
  end

  def source
    Unparser::CLI::Source::Original.new(node, parser_source, parser)
  end
  memoize :source

  def parser
    parser = Unparser.parser.tap do |parser|
      %w(foo bar baz).each(&parser.static_env.method(:declare))
    end
  end
end

module Minitest
  class Test
  end # Test
end # Minitest

module Extractor
  TESTS = []

  def self.node(node, source)
    @node   = node
    @source = source
  end

  def self.call(name)
    @node = @source = nil
    TestParser.new.send(name)

    if @node
      TESTS << Test.new(name, @node, @source)
    end
  end
end

require '../parser/test/test_parser.rb'

TestParser.instance_methods.grep(/\Atest_/).each(&Extractor.method(:call))

puts "Extracted: #{Extractor::TESTS.length} tests from parser"

Extractor::TESTS.sort_by(&:name).each do |test|
  test.run
end
