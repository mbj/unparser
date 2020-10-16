require 'spec_helper'

describe Unparser::Validation do
  let(:object) do
    described_class.new(
      identification:   identification,
      generated_node:   generated_node,
      generated_source: generated_source,
      original_node:    original_node,
      original_source:  original_source
    )
  end

  def right(value)
    MPrelude::Either::Right.new(value)
  end

  def left(value)
    MPrelude::Either::Left.new(value)
  end

  let(:generated_node)   { right(s(:send, s(:int, 1), :foo)) }
  let(:generated_source) { right('1.foo')                    }
  let(:identification)   { 'example-identification'          }
  let(:original_node)    { right(s(:send, s(:int, 1), :foo)) }
  let(:original_source)  { right('1.foo')                    }

  let(:exception) do
    left(
      instance_double(
        RuntimeError,
        message: 'foo',
        backtrace: Array.new(21, &'line-%02d'.method(:%))
      )
    )
  end

  let(:exception_report) do
    <<~'REPORT'.strip
      #<InstanceDouble(RuntimeError) (anonymous)>
      line-00
      line-01
      line-02
      line-03
      line-04
      line-05
      line-06
      line-07
      line-08
      line-09
      line-10
      line-11
      line-12
      line-13
      line-14
      line-15
      line-16
      line-17
      line-18
      line-19
    REPORT
  end

  def report
    object.report
  end

  shared_examples 'not successful' do
    it 'is not successful' do
      expect(object.success?).to be(false)
    end
  end

  context 'on success' do
    it 'is successful' do
      expect(object.success?).to be(true)
    end

    it 'returns expected report' do
      expect(report).to eql(<<~'REPORT'.strip)
        example-identification
        Original-Source:
        1.foo
        Generated-Source:
        1.foo
        Original-Node:
        (send
          (int 1) :foo)
        Generated-Node:
        (send
          (int 1) :foo)
      REPORT
    end
  end

  context 'on failing to generate original source with exception' do
    let(:original_source) { exception }

    include_examples 'not successful'

    it 'returns expected report' do
      expect(report).to eql(<<~REPORT.strip)
        example-identification
        Original-Source:
        #{exception_report}
        Generated-Source:
        1.foo
        Original-Node:
        (send
          (int 1) :foo)
        Generated-Node:
        (send
          (int 1) :foo)
      REPORT
    end
  end

  context 'on failing to parse generated source due precondition error' do
    let(:generated_node) { left(nil) }

    include_examples 'not successful'

    it 'returns expected report' do
      expect(report).to eql(<<~REPORT.strip)
        example-identification
        Original-Source:
        1.foo
        Generated-Source:
        1.foo
        Original-Node:
        (send
          (int 1) :foo)
        Generated-Node:
        undefined
      REPORT
    end
  end

  context 'on failing to parse original source' do
    let(:original_node) { exception }

    include_examples 'not successful'

    it 'returns expected report' do
      expect(report).to eql(<<~REPORT.strip)
        example-identification
        Original-Source:
        1.foo
        Generated-Source:
        1.foo
        Original-Node:
        #{exception_report}
        Generated-Node:
        (send
          (int 1) :foo)
      REPORT
    end
  end

  context 'on failing to generate generated source' do
    let(:generated_source) { exception }

    include_examples 'not successful'

    it 'returns expected report' do
      expect(report).to eql(<<~REPORT.strip)
        example-identification
        Original-Source:
        1.foo
        Generated-Source:
        #{exception_report}
        Original-Node:
        (send
          (int 1) :foo)
        Generated-Node:
        (send
          (int 1) :foo)
      REPORT
    end
  end

  context 'on failing to parse generated source' do
    let(:generated_node) { exception }

    include_examples 'not successful'

    it 'returns expected report' do
      expect(report).to eql(<<~REPORT.strip)
        example-identification
        Original-Source:
        1.foo
        Generated-Source:
        1.foo
        Original-Node:
        (send
          (int 1) :foo)
        Generated-Node:
        #{exception_report}
      REPORT
    end
  end

  context 'on generating different node' do
    let(:generated_node) { right(s(:send, s(:int, 1), :bar)) }

    include_examples 'not successful'

    it 'returns expected report' do
      diff = [
        Unparser::Color::NONE.format(" (send\n"),
        Unparser::Color::RED.format("-  (int 1) :foo)\n"),
        Unparser::Color::GREEN.format("+  (int 1) :bar)\n")
      ]

      expect(report).to eql(<<~'REPORT' + diff.join)
        example-identification
        Original-Source:
        1.foo
        Generated-Source:
        1.foo
        Original-Node:
        (send
          (int 1) :foo)
        Generated-Node:
        (send
          (int 1) :bar)
        Node-Diff:
        @@ -1,3 +1,3 @@
      REPORT
    end
  end

  describe '.from_path' do
    def apply
      described_class.from_path(path)
    end

    let(:path)   { instance_double(Pathname, read: source, to_s: '/some/file') }
    let(:source) { 'true'                                                      }

    it 'returns expected validator' do
      expect(apply).to eql(
        described_class.new(
          generated_node:   right(s(:true)),
          generated_source: right(source),
          identification:   '/some/file',
          original_node:    right(s(:true)),
          original_source:  right(source)
        )
      )
    end
  end

  describe '.from_string' do
    def apply
      described_class.from_string(source)
    end

    let(:attributes) do
      {
        generated_node:   right(s(:true)),
        generated_source: right(source),
        identification:   '(string)',
        original_node:    right(s(:true)),
        original_source:  right(source)
      }
    end

    context 'on valid original source' do
      let(:source) { 'true' }

      it 'returns expected validator' do
        expect(apply).to eql(described_class.new(attributes))
      end

      context 'with unparsing error' do
        let(:exception) { RuntimeError.new('example-error') }

        before do
          allow(Unparser).to receive(:unparse).and_raise(exception)
        end

        it 'returns expected validator' do
          validator = apply

          expect(validator.generated_node).to eql(left(nil))
          expect(validator.generated_source.from_left.class).to be(RuntimeError)
          expect(validator.original_source).to eql(right(source))
          expect(validator.original_node).to eql(right(s(:true)))
        end
      end
    end

    context 'on invalid original source' do
      let(:source) { '(' }

      it 'returns expected validator' do
        validator = apply

        expect(validator.generated_node).to eql(left(nil))
        expect(validator.generated_source).to eql(left(nil))
        expect(validator.original_source).to eql(right(source))
        expect(validator.original_node.from_left.class).to be(Parser::SyntaxError)
      end
    end
  end

  describe '.from_node' do
    def apply
      described_class.from_node(node)
    end

    let(:attributes) do
      {
        generated_node:   right(s(:true)),
        generated_source: right('true'),
        identification:   '(string)',
        original_node:    right(node),
        original_source:  right('true')
      }
    end

    context 'on valid original node' do
      let(:node) { s(:true) }

      it 'returns expected validator' do
        expect(apply).to eql(described_class.new(attributes))
      end
    end

    context 'on invalid original node' do
      let(:node) { s(:foo) }

      it 'returns expected validator' do
        validator = apply

        expect(validator.generated_node).to eql(left(nil))
        expect(validator.generated_source.lmap(&:inspect)).to eql(left(Unparser::UnknownNodeError.new('Unknown node type: :foo').inspect))
        expect(validator.original_source).to eql(validator.generated_source)
        expect(validator.original_node).to eql(right(node))
      end
    end
  end
end
