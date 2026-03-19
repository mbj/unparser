# frozen_string_literal: true

RSpec.describe Unparser::AST::Enumerator do
  let(:controller) { ->(node) { true } }

  let(:root) do
    s(:begin,
      s(:lvasgn, :foo, s(:int, 1)),
      s(:send, nil, :bar),
      s(:lvar, :foo))
  end

  subject { described_class.new(root, controller) }

  describe '#type' do
    it 'selects only nodes of the given type' do
      result = subject.type(:lvar)
      expect(result.map(&:type)).to eql(%i[lvar])
    end

    it 'returns empty when no nodes match' do
      result = subject.type(:class)
      expect(result).to be_empty
    end

    it 'does not return nodes of a different type' do
      result = subject.type(:lvasgn)
      expect(result.map(&:type).uniq).to eql(%i[lvasgn])
    end
  end
end
