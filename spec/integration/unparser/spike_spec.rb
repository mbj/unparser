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
  
  def self.strip(ruby)
    lines = ruby.lines
    line = lines.first
    match = /\A[ ]*/.match(line)
    length = match[0].length
    source = lines.map do |line|
      line[(length..-1)]
    end.join
    source.chomp
  end

  def assert_round_trip(input, parser)
    ast = parser.parse(input)
    generated = Unparser.unparse(ast)
    generated.should eql(input)
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

  def self.assert_source(input, versions = RUBIES)
    assert_round_trip(strip(input), versions)
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
      assert_source %q("\"")
      assert_source %q("foo#{1}bar")
      assert_source %q("\"#{@a}")
    end

    context 'execute string' do
      assert_round_trip '`foo`'
      assert_round_trip '`foo#{@bar}`'
      assert_generates  '%x(\))', '`)`'
     #assert_generates  '%x(`)', '`\``'
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
      assert_source %q("foo#{@bar}")
      assert_source     %q("fo\no#{bar}b\naz")
    end

    context 'irange' do
      assert_generates '1..2', %q(1..2)
    end

    context 'erange' do
      assert_generates '1...2', %q(1...2)
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

  context 'magic keywords' do
    assert_generates  '__ENCODING__', 'Encoding::UTF_8', RUBIES - %w(1.8)
    assert_round_trip '__FILE__'
    assert_round_trip '__LINE__'
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
      assert_round_trip 'a.foo, a.bar = 1, 2'
      assert_round_trip 'a[0, 2]'
      assert_round_trip 'a[0], a[1] = 1, 2'
      assert_round_trip 'a[*foo], a[1] = 1, 2'
      assert_round_trip '@@a, @@b = 1, 2'
      assert_round_trip '$a, $b = 1, 2'
      assert_round_trip 'a, b = foo'
    end
  end

  context 'return' do
    assert_source <<-RUBY
      return
    RUBY

    assert_source <<-RUBY
      return(1)
    RUBY
  end

  context 'send' do
    assert_round_trip 'foo'
    assert_round_trip 'self.foo'
    assert_round_trip 'a.foo'
    assert_round_trip 'A.foo'
    assert_round_trip 'foo[1]'
    assert_round_trip 'foo(1)'
    assert_round_trip 'foo(bar)'
    assert_round_trip 'foo(&block)'
    assert_round_trip 'foo(*arguments)'
    assert_round_trip "foo do\n\nend"
    assert_round_trip "foo(1) do\n\nend"
    assert_round_trip "foo do |a, b|\n\nend"
    assert_round_trip "foo do |a, *b|\n\nend"
    assert_round_trip "foo do |a, *|\n\nend"
    assert_round_trip "foo do\n  bar\nend"
  end

  context 'begin; end' do
    assert_source <<-RUBY
      begin
        foo
        bar
      end
    RUBY

    assert_source <<-RUBY
      begin
        foo
        bar
      end.blah
    RUBY
  end

  context 'begin / rescue / ensure' do
    assert_source <<-RUBY
      begin
        foo
      ensure
        baz
      end
    RUBY

    assert_source <<-RUBY
      begin
        foo
      rescue
        baz
      end
    RUBY

    assert_source <<-RUBY
      begin
        begin
          foo
          bar
        end
      rescue
        baz
      end
    RUBY

    assert_source <<-RUBY
      begin
        foo
      rescue Exception
        bar
      end
    RUBY

    assert_source <<-RUBY
      begin
        foo
      rescue => bar
        bar
      end
    RUBY

    assert_source <<-RUBY
      begin
        foo
      rescue Exception, Other => bar
        bar
      end
    RUBY

    assert_source <<-RUBY
      begin
        foo
      rescue Exception => bar
        bar
      end
    RUBY

    assert_source <<-RUBY
      begin
        bar
      rescue SomeError, *bar
        baz
      end
    RUBY

    assert_source <<-RUBY
      begin
        bar
      rescue SomeError, *bar => exception
        baz
      end
    RUBY

    assert_source <<-RUBY
      begin
        bar
      rescue *bar
        baz
      end
    RUBY

    assert_source <<-RUBY
      begin
        bar
      rescue *bar => exception
        baz
      end
    RUBY
  end

  context 'undef' do
    assert_source 'undef :foo'
  end

  context 'define' do
    context 'on instance' do

      assert_source <<-RUBY
        def foo
          bar
        end
      RUBY

      assert_source <<-RUBY
        def foo(bar)
          bar
        end
      RUBY

      assert_source <<-RUBY
        def foo(bar, baz)
          bar
        end
      RUBY

      assert_source <<-RUBY
        def foo(bar = true)
          bar
        end
      RUBY

      assert_source <<-RUBY
        def foo(bar, baz = true)
          bar
        end
      RUBY

      assert_source <<-RUBY
        def foo(*)
          bar
        end
      RUBY
      
      assert_source <<-RUBY
        def foo(*bar)
          bar
        end
      RUBY

      assert_source <<-RUBY
        def foo(bar, *baz)
          bar
        end
      RUBY

      assert_source <<-RUBY
        def foo(baz = true, *bor)
          bar
        end
      RUBY

      assert_source <<-RUBY
        def foo(baz = true, *bor, &block)
          bar
        end
      RUBY

      assert_source <<-RUBY
        def foo(bar, baz = true, *bor)
          bar
        end
      RUBY

      assert_source <<-RUBY
        def foo(&block)
          bar
        end
      RUBY

      assert_source <<-RUBY
        def foo(bar, &block)
          bar
        end
      RUBY

      assert_source <<-RUBY
        def initialize(attributes, options)
          begin
            @attributes = freeze_object(attributes)
            @options = freeze_object(options)
            @attribute_for = Hash[@attributes.map do |attribute|
              attribute.name
            end.zip(@attributes)]
            @keys = coerce_keys
          end
        end
      RUBY
    end

    context 'on singleton' do

      assert_source <<-RUBY
        def self.foo
          bar
        end
      RUBY

      assert_source <<-RUBY
        def Foo.bar
          bar
        end
      RUBY

    end

    context 'class' do
      assert_source <<-RUBY
        class TestClass

        end
      RUBY

      assert_source <<-RUBY
        class << some_object

        end
      RUBY

      assert_source <<-RUBY
        class << some_object
          the_body
        end
      RUBY

      assert_source <<-RUBY
        class SomeNameSpace::TestClass

        end
      RUBY

      assert_source <<-RUBY
        class Some::Name::Space::TestClass

        end
      RUBY

      assert_source <<-RUBY
        class TestClass < Object

        end
      RUBY

      assert_source <<-RUBY
        class TestClass < SomeNameSpace::Object

        end
      RUBY

      assert_source <<-RUBY
        class TestClass
          def foo
            :bar
          end
        end
      RUBY

      assert_source <<-RUBY
        class ::TestClass

        end
      RUBY
    end

    context 'module' do

      assert_source <<-RUBY 
        module TestModule

        end
      RUBY

      assert_source <<-RUBY
        module SomeNameSpace::TestModule

        end
      RUBY

      assert_source <<-RUBY
        module Some::Name::Space::TestModule

        end
      RUBY

      assert_source <<-RUBY
        module TestModule
          def foo
            :bar
          end
        end
      RUBY

    end

    context 'op assign' do

      %w(|= ||= &= &&= += -= *= /= **= %=).each do |op|
        assert_source "self.foo #{op} bar"
        assert_source "foo[key] #{op} bar"
      end

    end

    context 'element assignment' do
      assert_source 'array[index] = value'
      assert_source 'array[*index] = value'

      %w(+ - * / % & | || &&).each do |operator|
        context "with #{operator}" do
          assert_source "array[index] #{operator}= 2"
          assert_source "array[] #{operator}= 2"
        end
      end
    end

    context 'defined?' do
      context 'with instance varialbe' do
        assert_source <<-RUBY
          defined?(@foo)
        RUBY

        assert_source <<-RUBY
          defined?(Foo)
        RUBY
      end
    end
  end
end
