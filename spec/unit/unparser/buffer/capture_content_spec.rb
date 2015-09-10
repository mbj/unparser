require 'spec_helper'

describe Unparser::Buffer, '#capture_content' do

  let(:object) { described_class.new }

  it 'should capture only the content appended within the block' do
    object.append('foo')
    object.nl
    object.indent
    captured = object.capture_content do
      object.append('bar')
      object.nl
    end
    expect(captured).to eql("  bar\n")
  end
end
