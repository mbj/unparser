require 'spec_helper'
require 'parser/all'

describe Unparser, mutant_expression: 'Unparser::Emitter*' do
  describe '.unparse' do

    PARSERS = IceNine.deep_freeze(
      '2.1' => Parser::Ruby21,
      '2.2' => Parser::Ruby22,
      '2.3' => Parser::Ruby23
    )

    RUBIES = PARSERS.keys.freeze

    def self.parser_for_ruby_version(version)
      PARSERS.fetch(version) do
        raise "Unrecognized Ruby version #{version}"
      end
    end

    def self.with_versions(versions)
      versions.each do |version|
        yield parser_for_ruby_version(version)
      end
    end

    def assert_round_trip(input, parser)
      ast, comments = parser.parse_with_comments(input)
      generated = Unparser.unparse(ast, comments)
      expect(generated).to eql(input)
      generated_ast, _comments = parser.parse_with_comments(generated)
      expect(ast == generated_ast).to be(true)
    end

    def assert_generates_from_string(parser, string, expected)
      string = strip(string)
      ast_with_comments = parser.parse_with_comments(string)
      assert_generates_from_ast(parser, ast_with_comments, expected)
    end

    def assert_generates_from_ast(parser, ast_with_comments, expected)
      generated = Unparser.unparse(*ast_with_comments)
      expect(generated).to eql(expected)
      ast, comments = parser.parse_with_comments(generated)
      expect(Unparser.unparse(ast, comments)).to eql(expected)
    end

    def self.assert_unterminated(expression)
      assert_source(expression)
      assert_source("(#{expression}).foo")
    end

    def self.assert_terminated(expression, rubies = RUBIES)
      assert_source(expression, rubies)
      assert_source("foo(#{expression})", rubies)
      assert_source("#{expression}.foo", rubies)
    end

    def self.assert_generates(ast_or_string, expected, versions = RUBIES)
      with_versions(versions) do |parser|
        it "should generate #{ast_or_string} as #{expected} under #{parser.inspect}" do
          if ast_or_string.is_a?(String)
            expected = strip(expected)
            assert_generates_from_string(parser, ast_or_string, expected)
          else
            assert_generates_from_ast(parser, [ast_or_string, []], expected)
          end
        end
      end
    end

    def self.assert_round_trip(input, versions = RUBIES)
      with_versions(versions) do |parser|
        it "should round trip #{input} under #{parser.inspect}" do
          assert_round_trip(input, parser)
        end
      end
    end

    def self.assert_source(input, versions = RUBIES)
      assert_round_trip(strip(input), versions)
    end

    context 'kwargs' do
      assert_source <<-RUBY
        def foo(bar:, baz:)
        end
      RUBY

      assert_source <<-RUBY
        foo(**bar)
      RUBY

      assert_source <<-RUBY
        def foo(bar:, baz: "value")
        end
      RUBY
    end

    context 'literal' do
      context 'int' do
        assert_generates '-0', '0'
        assert_source '++1'
        assert_terminated '1'
        assert_unterminated '-1'
        assert_generates '0x1', '1'
        assert_generates '1_000', '1000'
        assert_generates '1e10',  '10000000000.0'
        assert_generates '10e10000000000', 'Float::INFINITY'
        assert_generates '-10e10000000000', '-Float::INFINITY'
      end

      context 'rational' do
        assert_terminated '1r'
        assert_generates '1.0r', '1r'
        assert_generates '-0r', '0r'

        assert_terminated '1.5r'
        assert_terminated '1.3r'
      end

      context 'complex' do
        %w(
          5i
          -5i
          0.6i
          -0.6i
          1000000000000000000000000000000i
          1ri
        ).each do |expression|
          assert_terminated(expression)
        end
      end

      context 'string' do
        assert_generates '?c',                 '"c"'
        assert_generates '"foo" "bar"',        '"#{"foo"}#{"bar"}"'
        assert_generates '"foo" "bar #{baz}"', '"#{"foo"}#{"#{"bar "}#{baz}"}"'
        assert_generates '%Q(foo"#{@bar})',    '"#{"foo\\""}#{@bar}"'
        assert_generates '"foo#{1}bar"',       '"#{"foo"}#{1}#{"bar"}"'
        assert_generates '"\\\\#{}"',          '"#{"\\\\"}#{}"'
        assert_generates '"#{}\#{}"',          '"#{}#{"\#{}"}"'
        assert_generates '"\#{}#{}"',          '"#{"\#{}"}#{}"'
        assert_terminated '"\""'
        assert_terminated '"foo bar"'
        assert_terminated '"foo\nbar"'
        # Within indentation
        assert_generates <<-'RUBY', <<-'RUBY'
          if foo
            "
            #{foo}
            "
          end
        RUBY
          if foo
            "#{"\n"}#{"  "}#{foo}#{"\n"}#{"  "}"
          end
        RUBY
      end

      context 'execute string' do
        assert_generates '`foo`',        '`#{"foo"}`'
        assert_generates '`foo#{@bar}`', '`#{"foo"}#{@bar}`'
        assert_generates '%x(\))',       '`#{")"}`'
        assert_generates '%x(`)',        '`#{"`"}`'
        assert_generates '`"`',          '`#{"\\""}`'
      end

      context 'symbol' do
        assert_generates s(:sym, :foo), ':foo'
        assert_generates s(:sym, :"A B"), ':"A B"'
        assert_terminated ':foo'
        assert_terminated ':"A B"'
        assert_terminated ':"A\"B"'
        assert_terminated ':""'
      end

      context 'regexp' do
        assert_terminated '/foo/'
        assert_terminated %q(/[^-+',.\/:@[:alnum:]\[\]]+/)
        assert_terminated '/foo#{@bar}/'
        assert_terminated '/foo#{@bar}/imx'
        assert_terminated '/#{"\u0000"}/'
        assert_terminated "/\n/"
        assert_terminated '/\n/'
        assert_terminated "/\n/x"
        # Within indentation
        assert_source <<-RUBY
          if foo
            /
            /
          end
        RUBY
        assert_generates '%r(/)', '/\//'
        assert_generates '%r(\))', '/\)/'
        assert_generates '%r(#{@bar}baz)', '/#{@bar}baz/'
        assert_terminated '/\/\//x'
      end

      context 'dynamic symbol' do
        assert_generates ':"foo#{bar}baz"', ':"#{"foo"}#{bar}#{"baz"}"'
        assert_source ':"#{"foo"}"'
      end

      context 'irange' do
        assert_unterminated '1..2'
        assert_unterminated '(0.0 / 0.0)..1'
        assert_unterminated '1..(0.0 / 0.0)'
        assert_unterminated '(0.0 / 0.0)..100'
      end

      context 'erange' do
        assert_unterminated '1...2'
      end

      context 'float' do
        assert_source '-0.1'
        assert_terminated '0.1'
        assert_terminated '0.1'
        assert_generates '10.2e10000000000', 'Float::INFINITY'
        assert_generates '-10.2e10000000000', '-Float::INFINITY'
        assert_generates s(:float, -0.1), '-0.1'
        assert_generates s(:float, 0.1), '0.1'
      end

      context 'array' do
        assert_terminated '[1, 2]'
        assert_terminated '[1, (), n2]'
        assert_terminated '[1]'
        assert_terminated '[]'
        assert_terminated '[1, *@foo]'
        assert_terminated '[*@foo, 1]'
        assert_terminated '[*@foo, *@baz]'
        assert_generates '%w(foo bar)', '["foo", "bar"]'
      end

      context 'hash' do
        assert_terminated '{}'
        assert_source '{ () => () }'
        assert_source '{ 1 => 2 }'
        assert_source '{ 1 => 2, 3 => 4 }'

        # special case for 2.1.3
        assert_source "{ foo: (if true\nend) }"

        context 'with symbol keys' do
          assert_source '{ a: (1 rescue foo), b: 2 }'
          assert_source '{ a: 1, b: 2 }'
          assert_source '{ a: :a }'
          assert_source '{ :"a b" => 1 }'
          assert_source '{ :-@ => 1 }'
        end
      end
    end

    context 'access' do
      %w(@a @@a $a $1 $` CONST SCOPED::CONST ::TOPLEVEL ::TOPLEVEL::CONST).each do |expression|
        assert_terminated(expression)
      end
    end

    context 'control keywords' do
      %w(retry redo).each do |expression|
        assert_terminated(expression)
      end
    end

    context 'singletons' do
      %w(self true false nil).each do |expression|
        assert_terminated(expression)
      end
    end

    context 'magic keywords' do
      assert_generates '__ENCODING__', 'Encoding::UTF_8'
      assert_generates '__FILE__', '"(string)"'
      assert_generates '__LINE__', '1'
    end

    context 'assignment' do
      context 'single' do
        assert_unterminated 'a = 1'
        assert_unterminated '@a = 1'
        assert_unterminated '@@a = 1'
        assert_unterminated '$a = 1'
        assert_unterminated 'CONST = 1'
        assert_unterminated 'Name::Spaced::CONST = 1'
        assert_unterminated '::Foo = ::Bar'
      end

      context 'lvar assigned from method with same name' do
        assert_unterminated 'foo = foo()'
      end

      context 'lvar introduction from condition' do
        assert_source 'foo = bar while foo'
        assert_source 'foo = bar until foo'
        assert_source <<-'RUBY'
          foo = exp
          while foo
            foo = bar
          end
        RUBY

        # Ugly I know. But its correct :D
        #
        # if foo { |pair| }
        #   pair = :foo
        #   foo
        # end
        assert_source <<-'RUBY'
          if foo do |pair|
            pair
          end
            pair = :foo
            foo
          end
        RUBY

        assert_source <<-'RUBY'
          while foo
            foo = bar
          end
        RUBY

        assert_source <<-'RUBY'
          each do |bar|
            while foo
              foo = bar
            end
          end
        RUBY

        assert_source <<-'RUBY'
          def foo
            foo = bar while foo != baz
          end
        RUBY

        assert_source <<-'RUBY'
          each do |baz|
            while foo
              foo = bar
            end
          end
        RUBY

        assert_source <<-'RUBY'
          each do |foo|
            while foo
              foo = bar
            end
          end
        RUBY
      end

      context 'multiple' do
        assert_source 'a, * = [1, 2]'
        assert_source 'a, *foo = [1, 2]'
        assert_source '*a = []'
        assert_source '*foo = [1, 2]'
        assert_source 'a, = foo'
        assert_unterminated 'a, b = [1, 2]'
        assert_unterminated '@a, @b = [1, 2]'
        assert_unterminated 'a.foo, a.bar = [1, 2]'
        assert_unterminated 'a[0], a[1] = [1, 2]'
        assert_unterminated 'a[*foo], a[1] = [1, 2]'
        assert_unterminated '@@a, @@b = [1, 2]'
        assert_unterminated '$a, $b = [1, 2]'
        assert_unterminated 'a, b = foo'
        assert_unterminated 'a, (b, c) = [1, [2, 3]]'
        assert_unterminated 'a = (b, c = 1)'
        assert_unterminated '(a,), b = 1'
      end
    end

    %w(next return break).each do |keyword|

      context keyword do
        assert_terminated keyword.to_s
        assert_unterminated "#{keyword} 1"
        assert_unterminated "#{keyword} 2, 3"
        assert_unterminated "#{keyword} *nil"
        assert_unterminated "#{keyword} *foo, bar"

        assert_generates <<-RUBY, <<-RUBY
          foo do |bar|
            bar =~ // || #{keyword}
            baz
          end
        RUBY
          foo do |bar|
            (bar =~ //) || #{keyword}
            baz
          end
        RUBY

        assert_generates <<-RUBY, <<-RUBY
          #{keyword}(a ? b : c)
        RUBY
          #{keyword} (if a
            b
          else
            c
          end)
        RUBY
      end
    end

    context 'conditional send (csend)' do
      assert_terminated 'a&.b',    %w(2.3)
      assert_terminated 'a&.b(c)', %w(2.3)
    end

    context 'send' do
      assert_terminated 'foo'
      assert_terminated 'self.foo'
      assert_terminated 'a.foo'
      assert_terminated 'A.foo'
      assert_terminated 'foo[]'
      assert_terminated 'foo[1]'
      assert_terminated 'foo[*baz]'
      assert_terminated 'foo(1)'
      assert_terminated 'foo(bar)'
      assert_terminated 'foo(&block)'
      assert_terminated 'foo(&(foo || bar))'
      assert_terminated 'foo(*arguments)'
      assert_terminated 'foo(*arguments)'
      assert_source <<-'RUBY'
        foo do
        end
      RUBY

      assert_source <<-'RUBY'
        foo(1) do
          nil
        end
      RUBY

      assert_source <<-'RUBY'
        foo do |a, b|
          nil
        end
      RUBY

      assert_source <<-'RUBY'
        foo do |a, *b|
          nil
        end
      RUBY

      assert_source <<-'RUBY'
        foo do |a, *|
          nil
        end
      RUBY

      assert_source <<-'RUBY'
        foo do
          bar
        end
      RUBY

      assert_source <<-'RUBY'
        foo.bar(*args)
      RUBY

      assert_source <<-'RUBY'
        foo.bar do |(a)|
          d
        end
      RUBY

      assert_source <<-'RUBY'
        foo.bar do |(a, b), c|
          d
        end
      RUBY

      assert_source <<-'RUBY'
        foo.bar do |*a; b|
        end
      RUBY

      assert_source <<-'RUBY'
        foo.bar do |a; b|
        end
      RUBY

      assert_source <<-'RUBY'
        foo.bar do |; a, b|
        end
      RUBY

      assert_source <<-'RUBY'
        foo.bar do |((*))|
          d
        end
      RUBY

      assert_source <<-'RUBY'
        foo.bar do |(a, (*))|
          d
        end
      RUBY

      assert_source <<-'RUBY'
        foo.bar do |(a, b)|
          d
        end
      RUBY

      assert_source <<-'RUBY'
        foo.bar do
        end.baz
      RUBY

      assert_terminated '(1..2).max'
      assert_terminated '1..2.max'
      assert_unterminated 'a || return'
      assert_unterminated 'foo << (bar * baz)'

      assert_source <<-'RUBY'
        foo ||= (a, _ = b)
      RUBY

      assert_source <<-'RUBY'
        begin
        rescue
        end.bar
      RUBY

      assert_source <<-'RUBY'
        case (def foo
        end
        :bar)
        when bar
        end.baz
      RUBY

      assert_source <<-'RUBY'
        case foo
        when bar
        end.baz
      RUBY

      assert_source <<-'RUBY'
        class << self
        end.bar
      RUBY

      assert_source <<-'RUBY'
        def self.foo
        end.bar
      RUBY

      assert_source <<-'RUBY'
        def foo
        end.bar
      RUBY

      assert_source <<-'RUBY'
        until foo
        end.bar
      RUBY

      assert_source <<-'RUBY'
        while foo
        end.bar
      RUBY

      assert_source <<-'RUBY'
        loop do
        end.bar
      RUBY

      assert_source <<-'RUBY'
        class Foo
        end.bar
      RUBY

      assert_source <<-'RUBY'
        module Foo
        end.bar
      RUBY

      assert_source <<-'RUBY'
        if foo
        end.baz
      RUBY

      assert_source <<-'RUBY'
        local = 1
        local.bar
      RUBY

      assert_terminated 'foo.bar(*args)'
      assert_terminated 'foo.bar(*arga, foo, *argb)'
      assert_terminated 'foo.bar(*args, foo)'
      assert_terminated 'foo.bar(foo, *args)'
      assert_terminated 'foo.bar(foo, *args, &block)'
      assert_source <<-'RUBY'
        foo(bar, *args)
      RUBY

      assert_terminated 'foo(*args, &block)'
      assert_terminated 'foo.bar(&baz)'
      assert_terminated 'foo.bar(:baz, &baz)'
      assert_terminated 'foo.bar = :baz'
      assert_unterminated 'self.foo = :bar'

      assert_terminated 'foo.bar(baz: boz)'
      assert_terminated 'foo.bar(foo, "baz" => boz)'
      assert_terminated 'foo.bar({ foo: boz }, boz)'
      assert_terminated 'foo.bar(foo, {})'
    end

    context 'begin; end' do
      assert_generates s(:begin), ''

      assert_source <<-'RUBY'
        begin
        end
      RUBY

      assert_source <<-'RUBY'
        foo
        bar
      RUBY

      assert_source <<-'RUBY'
        begin
          foo
          bar
        end.blah
      RUBY
    end

    context 'begin / rescue / ensure' do
      assert_source <<-'RUBY'
        begin
          foo
        ensure
          bar
          baz
        end
      RUBY

      assert_source <<-'RUBY'
        begin
          foo
        rescue
          baz
        end
      RUBY

      assert_source <<-'RUBY'
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

      assert_source <<-'RUBY'
        begin
          raise(Exception) rescue foo = bar
        rescue Exception
        end
      RUBY

      assert_source <<-'RUBY'
        begin
          foo
          bar
        rescue
          baz
          bar
        end
      RUBY

      assert_source <<-'RUBY'
        begin
          foo
        rescue Exception
          bar
        end
      RUBY

      assert_source <<-'RUBY'
        begin
          foo
        rescue => bar
          bar
        end
      RUBY

      assert_source <<-'RUBY'
        begin
          foo
        rescue Exception, Other => bar
          bar
        end
      RUBY

      assert_source <<-'RUBY'
        class << self
          undef :bar rescue nil
        end
      RUBY

      assert_source <<-'RUBY'
        module Foo
          undef :bar rescue nil
        end
      RUBY

      assert_source <<-'RUBY'
        class Foo
          undef :bar rescue nil
        end
      RUBY

      assert_source <<-'RUBY'
        begin
        rescue Exception => e
        end
      RUBY

      assert_source <<-'RUBY'
        begin
        ensure
        end
      RUBY

      assert_source <<-'RUBY'
        begin
        rescue
        ensure
        end
      RUBY

      assert_source <<-'RUBY'
        begin
          foo
        rescue Exception => bar
          bar
        end
      RUBY

      assert_source <<-'RUBY'
        begin
          bar
        rescue SomeError, *bar
          baz
        end
      RUBY

      assert_source <<-'RUBY'
        begin
          bar
        rescue SomeError, *bar => exception
          baz
        end
      RUBY

      assert_source <<-'RUBY'
        begin
          bar
        rescue *bar
          baz
        end
      RUBY

      assert_source <<-'RUBY'
        begin
          bar
        rescue LoadError
        end
      RUBY

      assert_source <<-'RUBY'
        begin
          bar
        rescue
        else
          baz
        end
      RUBY

      assert_source <<-'RUBY'
        begin
          bar
        rescue *bar => exception
          baz
        end
      RUBY

      assert_source 'foo rescue bar'
      assert_source 'foo rescue return bar'
      assert_source 'x = (foo rescue return bar)'

      %w(while until if).each do |keyword|
        assert_source <<-RUBY
          #{keyword} (
            foo rescue false
          )
          end
        RUBY

        assert_generates <<-RUBY, <<-GENERATED
          foo rescue false #{keyword} true
        RUBY
          #{keyword} true
            foo rescue false
          end
        GENERATED
      end

      assert_generates <<-'RUBY', <<-GENERATED
        case (foo rescue false)
        when true
        end
      RUBY
        case (
          foo rescue false
        )
        when true
        end
      GENERATED
    end

    context 'super' do
      assert_source 'super'

      assert_source 'super()'
      assert_source 'super(a)'
      assert_source 'super(a, b)'
      assert_source 'super(&block)'
      assert_source 'super(a, &block)'

      assert_source <<-'RUBY'
        super(a do
          foo
        end)
      RUBY

      assert_source <<-'RUBY'
        super do
          foo
        end
      RUBY

      assert_source <<-'RUBY'
        super(a) do
          foo
        end
      RUBY

      assert_source <<-'RUBY'
        super() do
          foo
        end
      RUBY

      assert_source <<-'RUBY'
        super(a, b) do
          foo
        end
      RUBY

    end

    context 'undef' do
      assert_source 'undef :foo'
      assert_source 'undef :foo, :bar'
    end

    context 'BEGIN' do
      assert_source <<-'RUBY'
        BEGIN {
          foo
        }
      RUBY
    end

    context 'END' do
      assert_source <<-'RUBY'
        END {
          foo
        }
      RUBY
    end

    context 'alias' do
      assert_source <<-'RUBY'
        alias $foo $bar
      RUBY

      assert_source <<-'RUBY'
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
      assert_source <<-'RUBY'
        if /foo/
          bar
        end
      RUBY

      assert_source <<-'RUBY'
        if 3
          9
        end
      RUBY

      assert_source <<-'RUBY'
        if 4
          5
        else
          6
        end
      RUBY

      assert_source <<-'RUBY'
        unless 3
          nil
        end
      RUBY

      assert_source <<-'RUBY'
        unless 3
          9
        end
      RUBY

      assert_source <<-'RUBY'
        if foo
        end
      RUBY

      assert_source <<-'RUBY'
        foo = bar if foo
      RUBY

      assert_source <<-'RUBY'
        foo = bar unless foo
      RUBY

      assert_source <<-'RUBY'
        def foo(*foo)
          unless foo
            foo = bar
          end
        end
      RUBY

      assert_source <<-'RUBY'
        each do |foo|
          unless foo
            foo = bar
          end
        end
      RUBY
    end

    context 'def' do
      context 'on instance' do

        assert_source <<-'RUBY'
          def foo
          end
        RUBY

        assert_source <<-'RUBY'
          def foo
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def foo
            foo
          rescue
            bar
          ensure
            baz
          end
        RUBY

        assert_source <<-'RUBY'
          begin
            foo
          ensure
            bar rescue nil
          end
        RUBY

        assert_source <<-'RUBY'
          def foo
            bar
          ensure
            baz
          end
        RUBY

        assert_source <<-'RUBY'
          def self.foo
            bar
          rescue
            baz
          end
        RUBY

        assert_source <<-'RUBY'
          def foo
            bar
          rescue
            baz
          end
        RUBY

        assert_source <<-'RUBY'
          def foo(bar)
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def foo(bar, baz)
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def foo(bar = ())
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def foo(bar = (baz
          nil))
          end
        RUBY

        assert_source <<-'RUBY'
          def foo(bar = true)
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def foo(bar, baz = true)
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def foo(bar: 1)
          end
        RUBY

        assert_source <<-'RUBY'
          def foo(*)
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def foo(*bar)
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def foo(bar, *baz)
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def foo(baz = true, *bor)
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def foo(baz = true, *bor, &block)
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def foo(bar, baz = true, *bor)
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def foo(&block)
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def foo(bar, &block)
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def foo
            bar
            baz
          end
        RUBY

        assert_source <<-'RUBY'
          def (foo do |bar|
          end).bar
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def (foo(1)).bar
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def (Foo::Bar.baz).bar
            baz
          end
        RUBY

        assert_source <<-'RUBY'
          def (Foo::Bar).bar
            baz
          end
        RUBY

        assert_source <<-'RUBY'
          def Foo.bar
            baz
          end
        RUBY

        assert_source <<-'RUBY'
          def foo.bar
            baz
          end
        RUBY
      end

      context 'on singleton' do
        assert_source <<-'RUBY'
          def self.foo
          end
        RUBY

        assert_source <<-'RUBY'
          def self.foo
            bar
          end
        RUBY

        assert_source <<-'RUBY'
          def self.foo
            bar
            baz
          end
        RUBY

        assert_source <<-'RUBY'
          def Foo.bar
            bar
          end
        RUBY

      end

      context 'class' do
        assert_source <<-'RUBY'
          class TestClass
          end
        RUBY

        assert_source <<-'RUBY'
          class << some_object
          end
        RUBY

        assert_source <<-'RUBY'
          class << some_object
            the_body
          end
        RUBY

        assert_source <<-'RUBY'
          class SomeNameSpace::TestClass
          end
        RUBY

        assert_source <<-'RUBY'
          class Some::Name::Space::TestClass
          end
        RUBY

        assert_source <<-'RUBY'
          class TestClass < Object
          end
        RUBY

        assert_source <<-'RUBY'
          class TestClass < SomeNameSpace::Object
          end
        RUBY

        assert_source <<-'RUBY'
          class TestClass
            def foo
              :bar
            end
          end
        RUBY

        assert_source <<-'RUBY'
          class ::TestClass
          end
        RUBY
      end

      context 'module' do

        assert_source <<-'RUBY'
          module TestModule
          end
        RUBY

        assert_source <<-'RUBY'
          module SomeNameSpace::TestModule
          end
        RUBY

        assert_source <<-'RUBY'
          module Some::Name::Space::TestModule
          end
        RUBY

        assert_source <<-'RUBY'
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
          assert_source "a #{op} (true\nfalse)"
        end
      end

      context 'element assignment' do
        assert_source 'foo[index] = value'
        assert_source 'foo[*index] = value'
        assert_source 'foo[a, b] = value'
        assert_source 'foo[1..2] = value'
        assert_source 'foo.[]=()'
        assert_source 'foo[] = 1'

        %w(+ - * / % & | || &&).each do |operator|
          context "with #{operator}" do
            assert_source "foo[index] #{operator}= 2"
            assert_source "foo[] #{operator}= 2"
          end
        end
      end

      context 'defined?' do
        assert_source <<-'RUBY'
          defined?(@foo)
        RUBY

        assert_source <<-'RUBY'
          defined?(Foo)
        RUBY

        assert_source <<-'RUBY'
          defined?((a, b = [1, 2]))
        RUBY
      end
    end

    context 'lambda' do
      assert_source <<-'RUBY'
        lambda do
        end
      RUBY

      assert_source <<-'RUBY'
        lambda do |a, b|
          a
        end
      RUBY
    end

    context 'match operators' do
      assert_source '/bar/ =~ foo'
      assert_source '/bar/ =~ :foo'
      assert_source '(/bar/ =~ :foo).foo'
      assert_source 'foo =~ /bar/'
      assert_source 'foo(foo =~ /bar/)'
      assert_source '(foo =~ /bar/).foo'
    end

    context 'binary operator methods' do
      %w(+ - * / & | << >> == === != <= < <=> > >= =~ !~ ^ **).each do |operator|
        assert_source "(-1) #{operator} 2"
        assert_source "(-1.2) #{operator} 2"
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
      assert_source 'a || (return foo)'
      assert_source '(return foo) || a'
      assert_source 'a || (break foo)'
      assert_source '(break foo) || a'
      assert_source '(a || b).foo'
      assert_source 'a || (b || c)'
    end

    { or: :'||', and: :'&&' }.each do |word, symbol|
      assert_generates "a #{word} return foo", "a #{symbol} (return foo)"
      assert_generates "a #{word} break foo", "a #{symbol} (break foo)"
      assert_generates "a #{word} next foo", "a #{symbol} (next foo)"
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
      assert_source '(h ||= {})[k] = v'
    end

    context 'flip flops' do
      context 'inclusive' do
        assert_source <<-'RUBY'
          if ((i == 4)..(i == 4))
            foo
          end
        RUBY
      end

      context 'exclusive' do
        assert_source <<-'RUBY'
          if ((i == 4)...(i == 4))
            foo
          end
        RUBY
      end
    end

    context 'case statement' do
      assert_source <<-'RUBY'
        case
        when bar
          baz
        when baz
          bar
        end
      RUBY

      assert_source <<-'RUBY'
        case foo
        when bar
        when baz
          bar
        end
      RUBY

      assert_source <<-'RUBY'
        case foo
        when bar
          baz
        when baz
          bar
        end
      RUBY

      assert_source <<-'RUBY'
        case foo
        when bar, baz
          :other
        end
      RUBY

      assert_source <<-'RUBY'
        case foo
        when *bar
          :value
        end
      RUBY

      assert_source <<-'RUBY'
        case foo
        when bar
          baz
        else
          :foo
        end
      RUBY
    end

    context 'for' do
      assert_source <<-'RUBY'
        bar(for a in bar do
          baz
        end)
      RUBY
      assert_source <<-'RUBY'
        for a in bar do
          baz
        end
      RUBY

      assert_source <<-'RUBY'
        for a, *b in bar do
          baz
        end
      RUBY

      assert_source <<-'RUBY'
        for a, b in bar do
          baz
        end
      RUBY
    end

    context 'unary operators' do
      assert_source '!1'
      assert_source '!(!1)'
      assert_source '!(!(foo || bar))'
      assert_source '!(!1).baz'
      assert_source '~a'
      assert_source '-a'
      assert_source '+a'
      assert_source '-(-a).foo'
    end

    context 'loop' do
      assert_source <<-'RUBY'
        loop do
          foo
        end
      RUBY
    end

    context 'post conditions' do
      assert_source <<-'RUBY'
        x = (begin
          foo
        end while baz)
      RUBY

      assert_source <<-'RUBY'
        begin
          foo
        end while baz
      RUBY

      assert_source <<-'RUBY'
        begin
          foo
          bar
        end until baz
      RUBY

      assert_source <<-'RUBY'
        begin
          foo
          bar
        end while baz
      RUBY
    end

    context 'while' do
      assert_source <<-'RUBY'
        while false
        end
      RUBY

      assert_source <<-'RUBY'
        while false
          3
        end
      RUBY

      assert_source <<-'RUBY'
        while (foo do
        end)
          :body
        end
      RUBY
    end

    context 'until' do
      assert_source <<-'RUBY'
        until false
        end
      RUBY

      assert_source <<-'RUBY'
        until false
          3
        end
      RUBY

      assert_source <<-'RUBY'
        until (foo do
        end)
          :body
        end
      RUBY
    end

    assert_source <<-'RUBY'
      # comment before
      a_line_of_code
    RUBY

    assert_source <<-'RUBY'
      a_line_of_code # comment after
    RUBY

    assert_source <<-'RUBY'
      nested do # first
        # second
        something # comment
        # another
      end
      # last
    RUBY

    assert_generates <<-'RUBY', <<-'RUBY'
      foo if bar
      # comment
    RUBY
      if bar
        foo
      end
      # comment
    RUBY

    assert_source <<-'RUBY'
      def noop
        # do nothing
      end
    RUBY

    assert_source <<-'RUBY'
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

    assert_generates(<<-'RUBY', <<-'RUBY')
      1 + # first
        2 # second
    RUBY
      1 + 2 # first # second
    RUBY

    assert_generates(<<-'RUBY', <<-'RUBY')
      1 +
        # first
        2 # second
    RUBY
      1 + 2 # first # second
    RUBY

    assert_generates(<<-'RUBY', <<-'RUBY')
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
