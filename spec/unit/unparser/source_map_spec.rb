# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Unparser::SourceMap::Entry do
  describe '#initialize' do
    it 'sets node and generated_range' do
      node  = s(:int, 42)
      entry = described_class.new(node: node, generated_range: 0...2)

      expect(entry.node).to equal(node)
      expect(entry.generated_range).to eql(0...2)
    end

    it 'freezes the entry' do
      entry = described_class.new(node: s(:int, 1), generated_range: 0...1)

      expect(entry).to be_frozen
    end
  end
end

RSpec.describe Unparser::SourceMap do
  describe '#record' do
    it 'appends an entry and returns self' do
      source_map = described_class.new
      node = s(:int, 42)

      result = source_map.record(node: node, generated_range: 0...2)

      expect(result).to equal(source_map)
      expect(source_map.entries.size).to eql(1)
      expect(source_map.entries.first.node).to equal(node)
      expect(source_map.entries.first.generated_range).to eql(0...2)
    end
  end

  describe '#for_node' do
    it 'returns entries matching by identity' do
      source_map = described_class.new
      node_a = s(:int, 1)
      node_b = s(:int, 2)
      source_map.record(node: node_a, generated_range: 0...1)
      source_map.record(node: node_b, generated_range: 2...3)
      expect(source_map.for_node(node_a).size).to eql(1)
      expect(source_map.for_node(node_a).first.generated_range).to eql(0...1)
    end

    it 'does not match structurally equal but distinct nodes' do
      source_map = described_class.new
      node_a = s(:int, 1)
      node_b = s(:int, 1)
      source_map.record(node: node_a, generated_range: 0...1)
      expect(source_map.for_node(node_b)).to eql([])
    end
  end

  describe '#freeze' do
    it 'freezes entries' do
      source_map = described_class.new
      source_map.freeze
      expect(source_map.entries).to be_frozen
    end

    it 'freezes the source map itself' do
      source_map = described_class.new
      source_map.freeze
      expect(source_map).to be_frozen
    end

    it 'prevents further recording' do
      source_map = described_class.new
      source_map.freeze
      expect { source_map.record(node: s(:int, 1), generated_range: 0...1) }.to raise_error(FrozenError)
    end
  end
end

RSpec.describe Unparser::Buffer do
  describe '#position' do
    let(:object) { described_class.new }

    it 'returns 0 for empty buffer' do
      expect(object.position).to eql(0)
    end

    it 'returns content length after appending' do
      object.append('foo')
      expect(object.position).to eql(3)
    end

    it 'reflects all accumulated content' do
      object.append('hello')
      object.nl
      object.append('world')
      expect(object.position).to eql(object.content.length)
    end
  end

  describe '#source_map' do
    it 'returns nil by default' do
      buffer = described_class.new
      expect(buffer.source_map).to be_nil
    end

    it 'returns the source map when provided' do
      source_map = Unparser::SourceMap.new
      buffer = described_class.new(source_map: source_map)
      expect(buffer.source_map).to equal(source_map)
    end
  end

  describe '#record_node' do
    context 'without source_map' do
      it 'yields and returns the block value' do
        buffer = described_class.new
        result = buffer.record_node(s(:int, 1)) { :value }
        expect(result).to eql(:value)
      end

      it 'does not raise' do
        buffer = described_class.new
        expect { buffer.record_node(s(:int, 1)) { buffer.append('x') } }.not_to raise_error
      end
    end

    context 'with source_map' do
      it 'records the node with its generated range' do
        source_map = Unparser::SourceMap.new
        buffer = described_class.new(source_map: source_map)
        node = s(:int, 42)

        buffer.append('prefix')
        buffer.record_node(node) { buffer.append('hello') }

        entries = source_map.for_node(node)
        expect(entries.size).to eql(1)
        expect(entries.first.generated_range).to eql(6...11)
        expect(entries.first.node).to equal(node)
      end

      it 'returns the block value' do
        source_map = Unparser::SourceMap.new
        buffer = described_class.new(source_map: source_map)
        result = buffer.record_node(s(:int, 1)) { :value }
        expect(result).to eql(:value)
      end

      it 'records an exclusive range' do
        source_map = Unparser::SourceMap.new
        buffer = described_class.new(source_map: source_map)
        node = s(:int, 1)

        buffer.record_node(node) { buffer.append('x') }

        expect(source_map.entries.first.generated_range.exclude_end?).to be(true)
      end
    end
  end
end

RSpec.describe Unparser, '.unparse_with_source_map' do
  context 'with nil node' do
    it 'returns empty string and empty frozen source map' do
      source, source_map = described_class.unparse_with_source_map(nil)
      expect(source).to eql('')
      expect(source_map.entries).to be_empty
      expect(source_map).to be_frozen
    end
  end

  context 'with a simple integer literal' do
    it 'maps the node to its generated range' do
      node = Unparser.parse('42')
      source, source_map = described_class.unparse_with_source_map(node)

      expect(source).to eql(Unparser.unparse(node))

      entries = source_map.for_node(node)
      expect(entries).not_to be_empty
      expect(entries.any? { |e| source[e.generated_range] == '42' }).to be(true)
    end
  end

  context 'with a method definition' do
    it 'maps parent and child nodes with exact ranges' do
      node = Unparser.parse("def foo\n  42\nend")
      source, source_map = described_class.unparse_with_source_map(node)

      expect(source).to eql("def foo\n  42\nend")

      # The def node should have entries
      def_entries = source_map.for_node(node)
      expect(def_entries).not_to be_empty
      expect(def_entries.any? { |e| source[e.generated_range].include?('def foo') }).to be(true)

      # The integer child node should map to an exact exclusive range
      # that starts AFTER position 0 (at the indented "  42")
      int_node = node.children.last
      int_entries = source_map.for_node(int_node)
      expect(int_entries).not_to be_empty

      int_entry = int_entries.first
      expect(int_entry.generated_range).to be_a(Range)
      expect(int_entry.generated_range.exclude_end?).to be(true)
      expect(int_entry.generated_range.begin).to be > 0
      expect(source[int_entry.generated_range]).to eql('  42')
    end
  end

  context 'with a local variable assignment' do
    it 'maps all nodes' do
      node = Unparser.parse('x = 1')
      source, source_map = described_class.unparse_with_source_map(node)

      expect(source).to eql(Unparser.unparse(node))
      expect(source_map.entries).not_to be_empty
    end
  end

  context 'with multiple statements' do
    it 'maps the root begin node' do
      node = Unparser.parse("x = 1\ny = 2")
      source, source_map = described_class.unparse_with_source_map(node)

      # The root begin node entry comes from emit_ast, not visit_deep
      root_entries = source_map.for_node(node)
      expect(root_entries).not_to be_empty
      expect(root_entries.first.node).to equal(node)
    end

    it 'maps each statement node' do
      node = Unparser.parse("x = 1\ny = 2")
      source, source_map = described_class.unparse_with_source_map(node)

      expect(source).to eql(Unparser.unparse(node))

      first_child = node.children.first
      second_child = node.children.last

      first_entries = source_map.for_node(first_child)
      second_entries = source_map.for_node(second_child)

      expect(first_entries).not_to be_empty
      expect(second_entries).not_to be_empty

      expect(first_entries.any? { |e| source[e.generated_range].include?('x = 1') }).to be(true)
      expect(second_entries.any? { |e| source[e.generated_range].include?('y = 2') }).to be(true)
    end
  end

  context 'with explicit_encoding' do
    it 'forwards encoding and affects output' do
      node = Unparser.parse('"hello"')
      source_without, = described_class.unparse_with_source_map(node)
      source_with, source_map = described_class.unparse_with_source_map(
        node,
        explicit_encoding: Encoding::BINARY
      )

      expect(source_with).not_to eql(source_without)
      expect(source_map.entries).not_to be_empty
    end
  end

  context 'generates the same source as unparse' do
    %w[
      42
      :foo
      "hello"
      x\ =\ 1
      def\ foo;\ end
      class\ Foo;\ end
      module\ Bar;\ end
    ].each do |code|
      it "for #{code.inspect}" do
        node = Unparser.parse(code)
        source, _source_map = described_class.unparse_with_source_map(node)
        expect(source).to eql(Unparser.unparse(node))
      end
    end
  end
end
