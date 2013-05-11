require 'spec_helper'

describe Unparser, 'spike' do

  let(:diagnostics) { [] }

  def parser_for_ruby_version(version)
    case version
    when '1.8'; parser = Parser::Ruby18.new
    # when '1.9'; parser = Parser::Ruby19.new # not yet
    # when '2.0'; parser = Parser::Ruby20.new # not yet
    else raise "Unrecognized Ruby version #{version}"
    end

    parser.diagnostics.consumer = lambda do |diagnostic|
      diagnostics << diagnostic
    end

    parser
  end

  def with_versions(code, versions)
    versions.each do |version|
      diagnostics.clear

      parser = parser_for_ruby_version(version)
      yield version, parser
    end
  end

  def assert_round_trip(input, versions = %w(1.8))
    with_versions(input, versions) do |version, parser|
      source = Parser::Source::Buffer.new('(unparser')
      source.source = input
      ast = parser.parse(source)
      Unparser.unparse(ast).should eql(input)
    end
  end

  def self.assert_round_trip(input, versions = %w(1.8))
    it "should round trip #{input.inspect}" do
      assert_round_trip(input, versions)
    end
  end

  context 'literal' do
    context 'fixnum' do
      assert_round_trip  '1'
      assert_round_trip '-1'
      assert_round_trip  '0'
    end

    context 'string' do
      assert_round_trip %q("foo")
      assert_round_trip %q("foo" "bar")
      assert_round_trip %q("foo#{1}bar")
      assert_round_trip %q("foo\n")
    end

    context 'irange' do
      assert_round_trip %q(1..2)
    end

    context 'erange' do
      assert_round_trip %q(1...2)
    end
  end
end
