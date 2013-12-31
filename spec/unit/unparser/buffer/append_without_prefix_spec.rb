# encoding: utf-8

require 'spec_helper'

describe Unparser::Buffer, '#append_without_prefix' do
  subject { object.append_without_prefix(string) }

  let(:object) { described_class.new }
  let(:string) { 'foo' }

  specify do
    expect { subject }.to change { object.content }.from('').to('foo')
  end

  it 'should not prefix with indentation' do
    object.append_without_prefix('foo')
    object.nl
    object.indent
    object.append_without_prefix('bar')
    object.append_without_prefix('baz')
    expect(object.content).to eql("foo\nbarbaz")
  end

  it_should_behave_like 'a command method'
end
