require 'spec_helper'

describe Unparser, 'spike' do


  PARSERS = IceNine.deep_freeze(
    '1.8' => Parser::Ruby18,
    '1.9' => Parser::Ruby19,
    '2.0' => Parser::Ruby20
  )

  RUBIES = PARSERS.keys.freeze

  def self.parser_for_ruby_version(version)
    PARSERS.fetch(version) do
      raise "Unrecognized Ruby version #{version}"
    end
  end

  def self.with_versions(versions)
    versions.each do |version|
      parser = parser_for_ruby_version(version)
      yield version, parser
    end
  end

  def assert_round_trip(input, parser)
    ast = parser.parse(input)
    Unparser.unparse(ast).should eql(input)
  end

  def self.assert_generates(ast, expected, versions = RUBIES)
    with_versions(versions) do |version, parser|
      it "should generate #{ast.inspect} as #{expected} under #{version}" do
        unless ast.kind_of?(Parser::AST::Node)
          ast = parser.parse(ast)
        end
        generated = Unparser.unparse(ast)
        generated.should eql(expected)
        ast = parser.parse(generated)
        Unparser.unparse(ast).should eql(expected)
      end
    end
  end

  def self.assert_round_trip(input, versions = RUBIES)
    with_versions(versions) do |version, parser|
      it "should round trip #{input.inspect} under #{version}" do
        assert_round_trip(input, parser)
      end
    end
  end

  context 'literal' do
    context 'fixnum' do
      assert_generates s(:int,  1),  '1'
      assert_generates s(:int, -1), '-1'
      assert_round_trip '1'
      assert_round_trip '0x1'
      assert_round_trip '1_000'
      assert_round_trip '1e10'
      assert_round_trip '?c'
    end

    context 'string' do
      assert_generates %q("foo" "bar"), %q("foobar")
      assert_generates %q(%Q(foo"#{@bar})), %q("foo\"#{@bar}")
      assert_round_trip %q("\"")
      assert_round_trip %q("foo#{1}bar")
      assert_round_trip %q("\"#{@a}")
    end

    context 'execute string' do
      assert_round_trip '`foo`'
      assert_round_trip '`foo#{@bar}`'
      assert_generates  '%x(\))', '`)`'
      assert_generates  '%x(`)', '`\``'
      assert_round_trip '`"`'
    end

    context 'symbol' do
      assert_generates s(:sym, :foo), ':foo'
      assert_generates s(:sym, :"A B"), ':"A B"'
      assert_round_trip ':foo'
      assert_round_trip ':"A B"'
      assert_round_trip ':"A\"B"'
    end

    context 'regexp' do
      assert_round_trip '/foo/'
      assert_round_trip %q(/[^-+',.\/:@[:alnum:]\[\]\x80-\xff]+/)
      assert_round_trip '/foo#{@bar}/'
      assert_round_trip '/foo#{@bar}/im'
      assert_generates '%r(/)', '/\//'
      assert_generates '%r(\))', '/)/'
      assert_generates '%r(#{@bar}baz)', '/#{@bar}baz/'
    end

    context 'dynamic string' do
      assert_round_trip %q("foo#{@bar}")
    end

    context 'irange' do
      assert_generates '1..2', %q((1..2))
    end

    context 'erange' do
      assert_generates '1...2', %q((1...2))
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
      assert_round_trip '[1, *@foo]'
      assert_round_trip '[*@foo, 1]',     RUBIES - %w(1.8)
      assert_round_trip '[*@foo, *@baz]', RUBIES - %w(1.8)
    end

    context 'hash' do
      assert_round_trip '{}'
      assert_round_trip '{1 => 2}'
      assert_round_trip '{1 => 2, 3 => 4}'
    end
  end

  context 'assignment' do
    context 'single' do
      assert_round_trip 'a = 1'
      assert_round_trip '@a = 1'
      assert_round_trip '@@a = 1'
      assert_round_trip '$a = 1'
      assert_round_trip 'CONST = 1'
    end

    context 'multiple' do
      assert_round_trip 'a, b = 1, 2'
      assert_round_trip 'a, *foo = 1, 2'
      assert_round_trip 'a, * = 1, 2'
      assert_round_trip '*foo = 1, 2'
      assert_round_trip '@a, @b = 1, 2'
     #assert_round_trip 'a.foo, a.bar = 1, 2'
     #assert_round_trip 'a[0], a[1] = 1, 2'
     #assert_round_trip 'a[*foo], a[1] = 1, 2'
      assert_round_trip '@@a, @@b = 1, 2'
      assert_round_trip '$a, $b = 1, 2'
     #assert_round_trip 'a, b = foo'
    end
  end

  context 'access' do
    assert_round_trip '@a'
    assert_round_trip '@@a'
    assert_round_trip '$a'
    assert_round_trip '$1'
    assert_round_trip '$`'
    assert_round_trip 'CONST'
    assert_round_trip 'SCOPED::CONST'
    assert_round_trip '::TOPLEVEL'
    assert_round_trip '::TOPLEVEL::CONST'
  end

  context 'singletons' do
    assert_round_trip 'self'
    assert_round_trip 'true'
    assert_round_trip 'false'
    assert_round_trip 'nil'
  end
end
