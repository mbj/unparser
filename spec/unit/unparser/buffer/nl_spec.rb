# encoding: utf-8

require 'spec_helper'

describe Unparser::Buffer, '#nl' do
  let(:object) { described_class.new }

  subject { object.nl }

  it 'writes a newline' do
    object.append('foo')
    subject
    object.append('bar')
    expect(object.content).to eql("foo\nbar")
  end

  it_should_behave_like 'a command method'
end
