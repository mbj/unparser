# encoding: utf-8

require 'spec_helper'

describe Unparser::Buffer, '#content' do
  subject { object.content }

  let(:object) { described_class.new }

  shared_examples_for 'buffer content' do
    it 'contains expected content' do
      should eql(expected_content)
    end

    it { should be_frozen }

    it 'returns fresh string copies' do
      first  = object.content
      second = object.content
      expect(first).to eql(second)
      expect(first).not_to be(second)
    end
  end

  context 'with empty buffer' do
    let(:expected_content) { '' }

    it_should_behave_like 'buffer content'
  end

  context 'with filled buffer' do
    before do
      object.append('foo')
    end

    let(:expected_content) { 'foo' }

    it_behaves_like 'buffer content'
  end
end
