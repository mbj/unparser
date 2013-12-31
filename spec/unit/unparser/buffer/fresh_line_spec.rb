# encoding: utf-8

require 'spec_helper'

describe Unparser::Buffer, '#fresh_line?' do
  let(:object) { described_class.new }

  it 'should return true while buffer is empty' do
    expect(object.fresh_line?).to eql(true)
  end

  it 'should return false after content has been appended' do
    object.append('foo')
    expect(object.fresh_line?).to eql(false)
  end

  it 'should return true after a nl has been appended' do
    object.append('foo')
    object.nl
    expect(object.fresh_line?).to eql(true)
  end
end
