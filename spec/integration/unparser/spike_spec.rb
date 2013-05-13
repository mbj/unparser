require 'spec_helper'

describe Unparser, 'spike' do

  def parser_for_ruby_version(version)
    case version
    when '1.8'
      Parser::Ruby18.new
    when '1.9' 
      Parser::Ruby19.new 
    when '2.0'
      Parser::Ruby20.new
    else 
      raise "Unrecognized Ruby version #{version}"
    end
  end

  def with_versions(code, versions)
    versions.each do |version|
      parser = parser_for_ruby_version(version)
      yield version, parser
    end
  end

  def assert_round_trip(input, versions = %w(1.8))
    with_versions(input, versions) do |version, parser|
      source = Parser::Source::Buffer.new('(unparser)')
      source.source = input
      ast = parser.parse(source)
      Unparser.unparse(ast).should eql(input)
    end
  end

  def self.assert_generates(ast, source)
    it "should generate #{ast} as #{source.inspect}" do
      Unparser.unparse(ast).should eql(source)
    end
  end

  def self.assert_round_trip(input, versions = %w(1.8))
    it "should round trip #{input.inspect}" do
      assert_round_trip(input, versions)
    end
  end

  context 'literal' do
    context 'fixnum' do
      assert_generates s(:int,  1), '1'
      assert_generates s(:int, -1), '-1'
      assert_round_trip '1'
      assert_round_trip '0x1'
      assert_round_trip '1_000'
      assert_round_trip '1e10'
      assert_round_trip '?c'
    end

    context 'string' do
      assert_generates s(:str, 'foo'), %q("foo")
      assert_generates s(:dstr, s(:str, "foo"), s(:str, "bar")), %q("foobar")
      assert_round_trip %q("foo#{1}bar")
    end

    context 'symbol' do
      assert_generates s(:sym, :foo), ':foo'
      assert_generates s(:sym, :"A B"), ':"A B"'
      assert_round_trip ':foo'
      assert_round_trip ':"A B"'
    end

    context 'regexp' do
      assert_round_trip '/foo/'
      assert_round_trip '/foo#{@bar}/'
      assert_round_trip '/foo#{@bar}/im'
    end

    context 'dynamic string' do
      assert_round_trip %q("foo#{@bar}")
    end

    context 'irange' do
      assert_generates s(:irange, s(:int, 1), s(:int, 2)), %q((1..2))
    end

    context 'erange' do
      assert_generates s(:erange, s(:int, 1), s(:int, 2)), %q((1...2))
    end

    context 'float' do
      assert_round_trip '-0.1'
      assert_round_trip '0.1'
      assert_generates s(:float, -0.1), '-0.1'
      assert_generates s(:float, 0.1), '0.1'
    end

    context 'array' do
      assert_round_trip '[1, 2]'
      assert_round_trip '[1]'
      assert_round_trip '[]'
    end

    context 'hash' do
      assert_round_trip '{}'
      assert_round_trip '{1 => 2}'
      assert_round_trip '{1 => 2, 3 => 4}'
    end
  end

  context 'assignment' do
    assert_round_trip 'a = 1'
    assert_round_trip '@a = 1'
    assert_round_trip '@@a = 1'
    assert_round_trip 'CONST = 1'
  end

  context 'access' do
    assert_round_trip '@a'
    assert_round_trip '@@a'
    assert_round_trip '$a'
    assert_round_trip '$1'
  end

  context 'singletons' do
    assert_round_trip 'self'
    assert_round_trip 'true'
    assert_round_trip 'false'
    assert_round_trip 'nil'
  end
end
