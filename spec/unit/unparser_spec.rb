require 'spec_helper'

describe Unparser do
  describe '.unparse' do

    PARSERS = IceNine.deep_freeze(
      '1.9' => Parser::Ruby19,
      '2.0' => Parser::Ruby20,
      '2.1' => Parser::Ruby21
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
      return ruby if ruby.empty?
      lines = ruby.lines
      line = lines.first
      match = /\A[ ]*/.match(line)
      length = match[0].length
      source = lines.map do |line|
        line[(length..-1)]
      end.join
      source.chomp
    end

    def assert_round_trip(input, parser_class)
      ast, comments = parser_class.parse_with_comments(input)
      generated = Unparser.unparse(ast, comments)
      generated.should eql(input)
    end

    def self.assert_generates_one_way(ast, expected, versions = RUBIES)
      with_versions(versions) do |version, parser_class|
        it "should generate #{ast.inspect} as #{expected} under #{version}" do
          comments = []
          if ast.kind_of?(String)
            ast, comments = parser_class.parse_with_comments(input)
          end
          generated = Unparser.unparse(ast, comments)
          generated.should eql(expected)
        end
      end
    end

    def self.assert_generates(ast_or_string, expected, versions = RUBIES)
      ast_or_string = strip(ast_or_string) if ast_or_string.is_a?(String)
      expected = strip(expected)
      with_versions(versions) do |version, parser_class|
        it "should generate #{ast_or_string.inspect} as #{expected} under #{version}" do
          ast, comments = if ast_or_string.kind_of?(String)
                            parser_class.parse_with_comments(ast_or_string)
                          else
                            [ast_or_string, []]
                          end
          generated = Unparser.unparse(ast, comments)
          generated.should eql(expected)
          ast, comments = parser_class.parse_with_comments(generated)
          Unparser.unparse(ast, comments).should eql(expected)
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
        assert_source '1'
        assert_generates '0x1', '1'
        assert_generates '1_000', '1000'
        assert_generates '1e10',  '10000000000.0'
        assert_generates '?c', '"c"'
      end

      context 'string' do
        assert_generates %q("foo" "bar"), %q("foobar")
        assert_generates %q(%Q(foo"#{@bar})), %q("foo\"#{@bar}")
        assert_source %q("\"")
        assert_source %q("foo#{1}bar")
        assert_source %q("\"#{@a}")
      end

      context 'execute string' do
        assert_source '`foo`'
        assert_source '`foo#{@bar}`'
        assert_generates  '%x(\))', '`)`'
       #assert_generates  '%x(`)', '`\``'
        assert_source '`"`'
      end

      context 'symbol' do
        assert_generates s(:sym, :foo), ':foo'
        assert_generates s(:sym, :"A B"), ':"A B"'
        assert_source ':foo'
        assert_source ':"A B"'
        assert_source ':"A\"B"'
      end

      context 'regexp' do
        assert_source '/foo/'
        assert_source %q(/[^-+',.\/:@[:alnum:]\[\]\x80-\xff]+/)
        assert_source '/foo#{@bar}/'
        assert_source '/foo#{@bar}/imx'
        assert_source "/\n/"
        assert_source '/\n/'
        assert_source "/\n/x"
        assert_generates '%r(/)', '/\//'
        assert_generates '%r(\))', '/)/'
        assert_generates '%r(#{@bar}baz)', '/#{@bar}baz/'
      end

      context 'dynamic string' do
        assert_source %q("foo#{@bar}")
        assert_source     %q("fo\no#{bar}b\naz")
      end

      context 'dynamic symbol' do
        assert_source ':"foo#{bar}baz"'
        assert_source ':"fo\no#{bar}b\naz"'
        assert_source ':"#{bar}foo"'
        assert_source ':"foo#{bar}"'
      end

      context 'irange' do
        assert_generates '1..2', %q(1..2)
        assert_source   '(0.0 / 0.0)..1'
        assert_source   '1..(0.0 / 0.0)'
        assert_source   '(0.0 / 0.0)..100'
      end

      context 'erange' do
        assert_generates '1...2', %q(1...2)
      end

      context 'float' do
        assert_source '-0.1'
        assert_source '0.1'
        assert_generates s(:float, -0.1), '-0.1'
        assert_generates s(:float, 0.1), '0.1'
      end

      context 'array' do
        assert_source '[1, 2]'
        assert_source '[1]'
        assert_source '[]'
        assert_source '[1, *@foo]'
        assert_source '[*@foo, 1]'
        assert_source '[*@foo, *@baz]'
        assert_generates '%w(foo bar)', %q(["foo", "bar"])
      end

      context 'hash' do
        assert_source '{}'
        assert_source '{1 => 2}'
        assert_source '{1 => 2, 3 => 4}'
      end
    end

    context 'access' do
      assert_source '@a'
      assert_source '@@a'
      assert_source '$a'
      assert_source '$1'
      assert_source '$`'
      assert_source 'CONST'
      assert_source 'SCOPED::CONST'
      assert_source '::TOPLEVEL'
      assert_source '::TOPLEVEL::CONST'
    end

    context 'break' do
      assert_source 'break'
      assert_source 'break(a)'
    end

    context 'next' do
      assert_source 'next'
      assert_source 'next(bar)'
    end

    context 'retry' do
      assert_source 'retry'
    end

    context 'redo' do
      assert_source 'redo'
    end

    context 'singletons' do
      assert_source 'self'
      assert_source 'true'
      assert_source 'false'
      assert_source 'nil'
    end

    context 'magic keywords' do
      assert_generates '__ENCODING__', 'Encoding::UTF_8'
      assert_source '__FILE__'
      assert_source '__LINE__'
    end

    context 'assignment' do
      context 'single' do
        assert_source 'a = 1'
        assert_source '@a = 1'
        assert_source '@@a = 1'
        assert_source '$a = 1'
        assert_source 'CONST = 1'
        assert_source 'Name::Spaced::CONST = 1'
      end

      context 'multiple' do
        assert_source 'a, b = 1, 2'
        assert_source 'a, *foo = 1, 2'
        assert_source 'a, * = 1, 2'
        assert_source '*foo = 1, 2'
        assert_source '@a, @b = 1, 2'
        assert_source 'a.foo, a.bar = 1, 2'
        assert_source 'a[0, 2]'
        assert_source 'a[0], a[1] = 1, 2'
        assert_source 'a[*foo], a[1] = 1, 2'
        assert_source '@@a, @@b = 1, 2'
        assert_source '$a, $b = 1, 2'
        assert_source 'a, b = foo'
        assert_source 'a, (b, c) = 1, [2, 3]'
        assert_generates_one_way s(:mlhs, s(:lvasgn, :a), s(:lvasgn, :b)), 'a, b'
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
      assert_source 'foo'
      assert_source 'self.foo'
      assert_source 'a.foo'
      assert_source 'A.foo'
      assert_source 'foo[1]'
      assert_source 'foo[*baz]'
      assert_source 'foo(1)'
      assert_source 'foo(bar)'
      assert_source 'foo(&block)'
      assert_source 'foo(*arguments)'
      assert_source 'foo(*arguments)'
      assert_source <<-RUBY
        foo do
        end
      RUBY

      assert_source <<-RUBY
        foo(1) do
          nil
        end
      RUBY

      assert_source <<-RUBY
        foo do |a, b|
          nil
        end
      RUBY

      assert_source <<-RUBY
        foo do |a, *b|
          nil
        end
      RUBY

      assert_source <<-RUBY
        foo do |a, *|
          nil
        end
      RUBY

      assert_source <<-RUBY
        foo do
          bar
        end
      RUBY

      assert_source <<-RUBY
        foo.bar(*args)
      RUBY

      assert_source <<-RUBY
        foo.bar do |(a, b), c|
          d
        end
      RUBY

      assert_source <<-RUBY
        foo.bar do |(a, b)|
          d
        end
      RUBY

      assert_source <<-RUBY
        foo.bar do
        end.baz
      RUBY

      assert_source '(1..2).max'
      assert_source '1..2.max'
      assert_source '(a = b).bar'
      assert_source '@ivar.bar'
      assert_source '//.bar'
      assert_source '$var.bar'
      assert_source '"".bar'
      assert_source 'defined?(@foo).bar'
      assert_source 'break.foo'
      assert_source 'next.foo'
      assert_source 'super(a).foo'
      assert_source 'a || return'
      assert_source 'super.foo'
      assert_source 'nil.foo'
      assert_source ':sym.foo'
      assert_source '1.foo'
      assert_source '1.0.foo'
      assert_source '[].foo'
      assert_source '{}.foo'
      assert_source 'false.foo'
      assert_source 'true.foo'
      assert_source 'self.foo'
      assert_source 'yield(a).foo'
      assert_source 'yield.foo'
      assert_source 'Foo::Bar.foo'
      assert_source '::BAZ.foo'
      assert_source 'array[i].foo'
      assert_source '(array[i] = 1).foo'
      assert_source 'array[1..2].foo'
      assert_source '(a.attribute ||= foo).bar'

      assert_source <<-RUBY
        begin
        rescue
        end.bar
      RUBY

      assert_source <<-RUBY
        case foo
        when bar
        end.baz
      RUBY

      assert_source <<-RUBY
        class << self
        end.bar
      RUBY

      assert_source <<-RUBY
        def self.foo
        end.bar
      RUBY

      assert_source <<-RUBY
        def foo
        end.bar
      RUBY

      assert_source <<-RUBY
        until foo
        end.bar
      RUBY

      assert_source <<-RUBY
        while foo
        end.bar
      RUBY

      assert_source <<-RUBY
        loop do
        end.bar
      RUBY

      assert_source <<-RUBY
        class Foo
        end.bar
      RUBY

      assert_source <<-RUBY
        module Foo
        end.bar
      RUBY

      assert_source <<-RUBY
        if foo
        end.baz
      RUBY

      assert_source <<-RUBY
        local = 1
        local.bar
      RUBY

      assert_source 'foo.bar(*args)'
      assert_source 'foo.bar(*arga, foo, *argb)'
      assert_source 'foo.bar(*args, foo)'
      assert_source 'foo.bar(foo, *args)'
      assert_source 'foo.bar(foo, *args, &block)'
      assert_source <<-RUBY
        foo(bar, *args)
      RUBY

      assert_source <<-RUBY
        foo(*args, &block)
      RUBY

      assert_source 'foo.bar(&baz)'
      assert_source 'foo.bar(:baz, &baz)'
      assert_source 'foo.bar=(:baz)'
      assert_source 'self.foo=(:bar)'
    end

    context 'begin; end' do
      assert_generates s(:begin), ''

      assert_source <<-RUBY
        foo
        bar
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
          bar
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
          rescue
          end
        rescue
          baz
          bar
        end
      RUBY

      assert_source <<-RUBY
        begin
          foo
          bar
        rescue
          baz
          bar
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
        rescue Exception => e
        end
      RUBY

      assert_source <<-RUBY
        begin
        rescue
        ensure
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
        rescue LoadError
        end
      RUBY

      assert_source <<-RUBY
        begin
          bar
        rescue
        else
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

    context 'super' do
      assert_source 'super'

      assert_source <<-RUBY
        super do
          foo
        end
      RUBY

      assert_source 'super()'

      assert_source <<-RUBY
        super() do
          foo
        end
      RUBY

      assert_source 'super(a)'

      assert_source <<-RUBY
        super(a) do
          foo
        end
      RUBY

      assert_source 'super(a, b)'

      assert_source <<-RUBY
        super(a, b) do
          foo
        end
      RUBY

      assert_source 'super(&block)'
      assert_source 'super(a, &block)'
    end

    context 'undef' do
      assert_source 'undef :foo'
    end

    context 'BEGIN' do
      assert_source <<-RUBY
        BEGIN {
          foo
        }
      RUBY
    end

    context 'END' do
      assert_source <<-RUBY
        END {
          foo
        }
      RUBY
    end

    context 'alias' do
      assert_source <<-RUBY
        alias $foo $bar
      RUBY

      assert_source <<-RUBY
        alias :foo :bar
      RUBY
    end

    context 'yield' do
      context 'without arguments' do
        assert_source 'yield'
      end

      context 'with argument' do
        assert_source 'yield(a)'
      end

      context 'with arguments' do
        assert_source 'yield(a, b)'
      end
    end

    context 'if statement' do
      assert_source <<-RUBY
        if /foo/
          bar
        end
      RUBY

      assert_source <<-RUBY
        if 3
          9
        end
      RUBY

      assert_source <<-RUBY
        if 4
          5
        else
          6
        end
      RUBY

      assert_source <<-RUBY
        unless 3
          nil
        end
      RUBY

      assert_source <<-RUBY
        unless 3
          9
        end
      RUBY

      assert_source <<-RUBY
        if foo
        end
      RUBY
    end

    context 'def' do
      context 'on instance' do

        assert_source <<-RUBY
          def foo
          end
        RUBY

        assert_source <<-RUBY
          def foo
            bar
          end
        RUBY

        assert_source <<-RUBY
          def foo
            bar
          ensure
            baz
          end
        RUBY

        assert_source <<-RUBY
          def foo
            bar
          rescue
            baz
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

        assert_source <<-RUBY, %w(1.9 2.0)
          def foo(bar, baz = true, foo)
            bar
          end
        RUBY

        assert_source <<-RUBY, %w(2.1)
          def foo(bar: 1)
          end
        RUBY

        assert_source <<-RUBY, %w(2.0)
          def foo(**bar)
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
          def foo
            bar
            baz
          end
        RUBY
      end

      context 'on singleton' do
        assert_source <<-RUBY
          def self.foo
          end
        RUBY


        assert_source <<-RUBY
          def self.foo
            bar
          end
        RUBY

        assert_source <<-RUBY
          def self.foo
            bar
            baz
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
          end # TestClass
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
          end # SomeNameSpace::TestClass
        RUBY

        assert_source <<-RUBY
          class Some::Name::Space::TestClass
          end # Some::Name::Space::TestClass
        RUBY

        assert_source <<-RUBY
          class TestClass < Object
          end # TestClass
        RUBY

        assert_source <<-RUBY
          class TestClass < SomeNameSpace::Object
          end # TestClass
        RUBY

        assert_source <<-RUBY
          class TestClass
            def foo
              :bar
            end
          end # TestClass
        RUBY

        assert_source <<-RUBY
          class ::TestClass
          end # ::TestClass
        RUBY
      end

      context 'module' do

        assert_source <<-RUBY
          module TestModule
          end # TestModule
        RUBY

        assert_source <<-RUBY
          module SomeNameSpace::TestModule
          end # SomeNameSpace::TestModule
        RUBY

        assert_source <<-RUBY
          module Some::Name::Space::TestModule
          end # Some::Name::Space::TestModule
        RUBY

        assert_source <<-RUBY
          module TestModule
            def foo
              :bar
            end
          end # TestModule
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
        assert_source <<-RUBY
          defined?(@foo)
        RUBY

        assert_source <<-RUBY
          defined?(Foo)
        RUBY
      end
    end

    context 'lambda' do
      assert_source <<-RUBY
        lambda do
        end
      RUBY

      assert_source <<-RUBY
        lambda do |a, b|
          a
        end
      RUBY
    end

    context 'match operators' do
      assert_source <<-RUBY
        /bar/ =~ foo
      RUBY

      assert_source <<-RUBY
        foo =~ /bar/
      RUBY
    end

    context 'binary operator methods' do
      %w(+ - * / & | << >> == === != <= < <=> > >= =~ !~ ^ **).each do |operator|
        assert_source "1 #{operator} 2"
        assert_source "left.#{operator}(*foo)"
        assert_source "left.#{operator}(a, b)"
        assert_source "self #{operator} b"
        assert_source "a #{operator} b"
        assert_source "(a #{operator} b).foo"
      end

      assert_source 'left / right'
    end

    context 'nested binary operators' do
      assert_source '(a + b) / (c - d)'
      assert_source '(a + b) / c.-(e, f)'
      assert_source '(a + b) / c.-(*f)'
    end

    context 'binary operator' do
      assert_source 'a || (break(foo))'
      assert_source '(break(foo)) || a'
      assert_source '(a || b).foo'
      assert_source 'a || (b || c)'
    end

    { :or => :'||', :and => :'&&' }.each do |word, symbol|
      assert_generates "a #{word} break foo", "a #{symbol} (break(foo))"
      assert_generates "a #{word} next foo", "a #{symbol} (next(foo))"
    end

    context 'expansion of shortcuts' do
      assert_source 'a += 2'
      assert_source 'a -= 2'
      assert_source 'a **= 2'
      assert_source 'a *= 2'
      assert_source 'a /= 2'
    end

    context 'shortcuts' do
      assert_source 'a &&= b'
      assert_source 'a ||= 2'
      assert_source '(a ||= 2).bar'
      assert_source '(a ||= 2).foo(1)'
      assert_source '(h ||= {})[k]'
      assert_source '(h ||= {})[k] = v'
    end

    context 'flip flops' do
      context 'inclusive' do
        assert_source <<-RUBY
          if (i == 4)..(i == 4)
            foo
          end
        RUBY
      end

      context 'exclusive' do
        assert_source <<-RUBY
          if (i == 4)...(i == 4)
            foo
          end
        RUBY
      end
    end

    context 'case statement' do
      assert_source <<-RUBY
        case
        when bar
          baz
        when baz
          bar
        end
      RUBY

      assert_source <<-RUBY
        case foo
        when bar
        when baz
          bar
        end
      RUBY


      assert_source <<-RUBY
        case foo
        when bar
          baz
        when baz
          bar
        end
      RUBY

      assert_source <<-RUBY
        case foo
        when bar, baz
          :other
        end
      RUBY

      assert_source <<-RUBY
        case foo
        when *bar
          :value
        end
      RUBY

      assert_source <<-RUBY
        case foo
        when bar
          baz
        else
          :foo
        end
      RUBY
    end

    context 'for' do
      assert_source <<-RUBY
        for a in bar do
          baz
        end
      RUBY

      assert_source <<-RUBY
        for a, *b in bar do
          baz
        end
      RUBY

      assert_source <<-RUBY
        for a, b in bar do
          baz
        end
      RUBY
    end

    context 'unary operators' do
      assert_source '!1'
      assert_source '!!1'
      assert_source '!(!1).baz'
      assert_source '~a'
      assert_source '-a'
      assert_source '+a'
    end

    context 'loop' do
      assert_source <<-RUBY
        loop do
          foo
        end
      RUBY
    end

    context 'post conditions' do
      assert_source <<-RUBY
        begin
          foo
        end while baz
      RUBY

      assert_source <<-RUBY
        begin
          foo
          bar
        end until baz
      RUBY

      assert_source <<-RUBY
        begin
          foo
          bar
        end while baz
      RUBY
    end

    context 'while' do
      assert_source <<-RUBY
        while false
        end
      RUBY

      assert_source <<-RUBY
        while false
          3
        end
      RUBY
    end

    context 'until' do
      assert_source <<-RUBY
        until false
        end
      RUBY

      assert_source <<-RUBY
        until false
          3
        end
      RUBY
    end

    context 'comments' do
      assert_source <<-RUBY
        # comment before
        a_line_of_code
      RUBY

      assert_source <<-RUBY
        a_line_of_code # comment after
      RUBY

      assert_source <<-RUBY
        nested do # first
          # second
          something # comment
          # another
        end
        # last
      RUBY

      assert_source <<-RUBY
        def noop
          # do nothing
        end
      RUBY

      assert_source <<-RUBY
        =begin
          block comment
        =end
        nested do
        =begin
        another block comment
        =end
          something
        =begin
        last block comment
        =end
        end
      RUBY

      assert_generates(<<-RUBY, <<-RUBY)
        1 + # first
          2 # second
      RUBY
        1 + 2 # first # second
      RUBY
      assert_generates(<<-RUBY, <<-RUBY)
        1 +
          # first
          2 # second
      RUBY
        1 + 2 # first # second
      RUBY
      assert_generates(<<-RUBY, <<-RUBY)
        1 +
        =begin
          block comment
        =end
          2
      RUBY
        1 + 2
        =begin
          block comment
        =end
      RUBY
    end
  end
end
