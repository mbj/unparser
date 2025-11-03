require 'spec_helper'

describe Unparser, mutant_expression: 'Unparser*' do
  describe '.buffer' do
    let(:source) { 'a + b' }

    def apply
      described_class.buffer(source)
    end

    it 'returns parser buffer with expected name' do
      expect(apply.name).to eql('(string)')
    end

    it 'returns parser buffer with pre-filled source' do
      expect(apply.source).to eql(source)
    end

    context 'on non default identification' do
      def apply
        described_class.buffer(source, '(foo)')
      end

      it 'returns parser buffer with expected name' do
        expect(apply.name).to eql('(foo)')
      end
    end
  end

  describe '.parser' do
    let(:invalid_source_buffer) { Unparser.buffer('a +') }

    def apply
      described_class.parser
    end

    context 'failure' do
      def apply
        super.tap do |parser|
          parser.diagnostics.consumer = ->(_) {}
        end
      end

      it 'returns a parser that fails with syntax error' do
        expect { apply.parse(invalid_source_buffer) }
          .to raise_error(Parser::SyntaxError)
      end
    end
  end

  describe '.parse' do
    def apply
      described_class.parse(source)
    end

    context 'on present source' do
      let(:source) { 'self[1]=2' }

      it 'returns expected AST' do
        expect(apply).to eql(s(:indexasgn, s(:self), s(:int, 1), s(:int, 2)))
      end
    end

    context 'on empty source' do
      let(:source) { '' }

      it 'returns ni' do
        expect(apply).to be(nil)
      end
    end

    context 'on syntax error' do
      let(:source) { '[' }

      it 'raises error' do
        expect { apply }.to raise_error(Parser::SyntaxError)
      end
    end
  end

  context '.parse_ast_either' do
    def apply
      described_class.parse_ast_either(source)
    end

    context 'on present source' do
      let(:source) { 'self[1]=2' }

      it 'returns right value with expected AST' do
        expect(apply.fmap(&:node)).to eql(right(s(:indexasgn, s(:self), s(:int, 1), s(:int, 2))))
      end
    end

    context 'on empty source' do
      let(:source) { '' }

      it 'returns right value with nil' do
        expect(apply.fmap(&:node)).to eql(right(nil))
      end
    end

    context 'on syntax error' do
      let(:source) { '[' }

      it 'returns left value with syntax error' do
        result = apply

        # Syntax errors that compare nicely under #eql? are hard to construct
        expect(result).to be_instance_of(Unparser::Either::Left)
        expect(result.from_left).to be_instance_of(Parser::SyntaxError)
      end
    end
  end

  describe '.unparse_validate' do
    def apply
      Unparser.unparse_validate(s(:true))
    end

    context 'on successful validation' do
      context 'with comments' do
        def apply
          node, comments = Unparser.parser.parse_with_comments(Unparser.buffer('true # foo'))
          Unparser.unparse_validate(node, comments:)
        end

        it 'returns right value with generated source' do
          expect(apply).to eql(right('true # foo'))
        end
      end

      context 'without comments' do
        it 'returns right value with generated source' do
          expect(apply).to eql(right('true'))
        end
      end
    end

    context 'on unsuccessful validation' do
      before do
        allow(Unparser::Validation).to receive_messages(from_string: validation)
      end

      let(:validation) do
        instance_double(Unparser::Validation, success?: false)
      end

      it 'returns left value with validation' do
        expect(apply).to eql(left(validation))
      end
    end
  end

  describe '.unparse_ast_either' do
    def apply
      described_class.unparse_ast_either(ast)
    end

    let(:ast) do
      described_class::AST.new(
        node:                   node,
        comments:               [],
        explicit_encoding:      nil,
        static_local_variables: Set.new
      )
    end

    context 'on valid node' do
      let(:node) { s(:true) }

      it 'returns expected source' do
        expect(apply).to eql(right('true'))
      end
    end

    context 'on invalid node' do
      let(:node) { s(:unsupported) }

      it 'returns expected error' do
        expect(apply.lmap { |value| [value.class, value.message] }).to eql(
          left(
            [
              described_class::UnknownNodeError,
              'Unknown node type: :unsupported'
            ]
          )
        )
      end
    end
  end

  describe '.unparse' do
    context 'on unknown node type' do
      def apply
        Unparser.unparse(node)
      end

      let(:node) { s(:example_node) }

      it 'raises UnknownNodeError' do
        expect { apply }.to raise_error(
          Unparser::UnknownNodeError,
          'Unknown node type: :example_node'
        )
      end
    end

    context 'with comments' do
      def apply
        node, comments = Unparser.parser.parse_with_comments(Unparser.buffer('true # foo'))
        Unparser.unparse(node, comments:)
      end

      it 'returns right value with generated source' do
        expect(apply).to eql('true # foo')
      end
    end

    def parser
      Unparser.parser
    end

    def buffer(input)
      Unparser.buffer(input)
    end

    def parse_with_comments(string)
      parser.parse_with_comments(buffer(string))
    end

    def assert_generates_from_string(parser, string, expected)
      node, comments = parse_with_comments(string)
      assert_generates_from_ast(parser, node, comments, expected.chomp)
    end

    def assert_generates_from_ast(parser, node, comments, expected)
      generated = Unparser.unparse(node, comments: comments).chomp
      expect(generated).to eql(expected)
      ast, comments = parse_with_comments(generated)
      expect(ast).to eql(ast)
      expect(Unparser.unparse(ast, comments:).chomp).to eql(expected)
    end

    def self.assert_generates(input, expected)
      it "should generate #{input} as #{expected}" do
        if input.is_a?(String)
          assert_generates_from_string(parser, input, expected)
        else
          assert_generates_from_ast(parser, [input, []], expected)
        end
      end
    end

    def self.assert_source(string)
      it 'round trips' do
        ast, comments = parse_with_comments(string)
        generated = Unparser.unparse(ast, comments:).chomp
        expect(generated).to eql(string.chomp)
        generated_ast, _comments = parse_with_comments(generated)
        expect(ast == generated_ast).to be(true)
      end
    end

    context 'on empty source' do
      assert_source ''
    end

    context 'invalid send selector' do
      let(:node) { s(:send, nil, :module) }

      it 'raises InvalidNode error' do
        expect { Unparser.unparse(node) }.to raise_error do |error|
          expect(error).to be_a(Unparser::InvalidNodeError)
          expect(error.message).to eql('Invalid selector for send node: :module')
          expect(error.node).to be(node)
        end
      end
    end

    %w(next return break).each do |keyword|
      context keyword do
        assert_source "#{keyword} 1"
        assert_source "#{keyword} 2, 3"
        assert_source "#{keyword} *nil"
        assert_source "#{keyword} *foo, bar"

        assert_source <<~RUBY
          foo { |bar|
            bar =~ // or #{keyword}
            baz
          }
        RUBY
      end
    end

    context 'op assign' do
      %w(|= ||= &= &&= += -= *= /= **= %=).each do |op|
        assert_source "self.foo #{op} bar"
        assert_source "foo[key] #{op} bar"
        assert_source "a #{op} (true; false)"
      end
    end

    context 'element assignment' do
      %w(+ - * / % & | || &&).each do |operator|
        context "with #{operator}" do
          assert_source "foo[index] #{operator}= 2"
          assert_source "foo[] #{operator}= 2"
        end
      end
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

    assert_source <<~'RUBY'
      # comment before
      a_line_of_code
    RUBY

    assert_source <<~'RUBY'
      a_line_of_code # comment after
    RUBY

    assert_source <<~'RUBY'
      nested {
        # first
        # second
        something # comment
      } # another
      # last
    RUBY

    assert_generates <<~'RUBY', <<~'RUBY'
      foo if bar
      # comment
    RUBY
      if bar
        foo
      end
      # comment
    RUBY

    assert_source <<~'RUBY'
      def noop
        # do nothing
      end
    RUBY

    assert_source <<~'RUBY'
      =begin
        block comment
      =end
      nested {
      =begin
      another block comment
      =end
        something
      }
      =begin
      last block comment
      =end
    RUBY

    assert_generates(<<~'RUBY', <<~'RUBY')
      1 + # first
        2 # second
    RUBY
      1 + 2 # first # second
    RUBY

    assert_generates(<<~'RUBY', <<~'RUBY')
      1 +
        # first
        2 # second
    RUBY
      1 + 2 # first # second
    RUBY

    assert_generates(<<~'RUBY', <<~'RUBY')
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

    assert_generates(<<~'RUBY', <<~'RUBY')
      true ? "true" : ()
    RUBY
      if true
        "true"
      else
        ()
      end
    RUBY

    assert_generates(<<~'RUBY', <<~'RUBY')
      true ? () : "false"
    RUBY
      if true
        ()
      else
        "false"
      end
    RUBY

    assert_source(<<~'RUBY')
      if true
        "true"
      else
        ()
      end
    RUBY

    assert_source(<<~'RUBY')
      if true
        ()
      else
        "false"
      end
    RUBY

    assert_source(<<~'RUBY')
      def foo(bar)
        bar()
      end
    RUBY

    assert_source(<<~'RUBY')
      foo { |bar|
        bar()
      }
    RUBY

    # Test Symbol#inspect Ruby bug: https://bugs.ruby-lang.org/issues/18905
    assert_source(':"@="')
    assert_source(':"$$$$="')
    assert_source(':"8 >="')
  end

  describe 'corpus' do
    let(:version_excludes) do
      excludes = []

      # "before/34.rb" contains syntax valid before Ruby 3.4 but invalid in 3.4+
      # So we need to exclude it on ALL versions (3.3 can't parse it, 3.4+ rejects it)
      excludes.concat(
        %w[
          test/corpus/literal/before/34.rb
        ]
      )

      excludes.flat_map { |file| ['--ignore', file] }
    end

    it 'passes the literal corpus' do
      expect(Unparser::CLI.run(%w[test/corpus/literal --literal] + version_excludes)).to be(0)
    end

    it 'passes the semantic corpus' do
      expect(Unparser::CLI.run(%w[test/corpus/semantic] + version_excludes)).to be(0)
    end
  end
end
