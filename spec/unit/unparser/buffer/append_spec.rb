# encoding: utf-8

require 'spec_helper'

describe Unparser::Buffer, '#append' do
  subject { object.append(string) }

  let(:object) { described_class.new }
  let(:string) { 'foo' }

  specify do
    expect { subject }.to change { object.content }.from('').to('foo')
  end

  # Yeah duplicate, mutant will be improved ;)
  it 'should prefix with indentation if line is empty' do
    object.append('foo')
    object.nl
    object.indent
    object.append('bar')
    object.append('baz')
    expect(object.content).to eql("foo\n  barbaz")
  end

  it_should_behave_like 'a command method'
end
