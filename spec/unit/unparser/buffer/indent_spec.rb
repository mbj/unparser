require 'spec_helper'

describe Unparser::Buffer, '#indent' do
  let(:object) { described_class.new }

  subject { object.indent }

  it 'should indent with two chars' do
    object.append('foo')
    object.indent
    object.append('bar')
    object.indent
    object.append('baz')
    expect(object.content).to eql("foo\n  bar\n    baz")
  end

  it_should_behave_like 'a command method'
end
