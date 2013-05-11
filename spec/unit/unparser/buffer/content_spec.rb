require 'spec_helper'

describe Unparser::Buffer, '#content' do
  subject { object.content }

  let(:object) { described_class.new }

  shared_examples_for 'buffer content' do
    it 'should contain expected content' do
      should eql(expected_content)
    end

    its(:frozen?) { should be(true) }

    it 'should return fresh string copies' do
      first  = object.content
      second = object.content
      first.should eql(second)
      first.should_not be(second)
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

    it_should_behave_like 'buffer content'
  end
end
