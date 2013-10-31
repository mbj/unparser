require 'spec_helper'

describe Unparser::Emitter::SourceMap, '.emit' do
  let(:object)  { described_class           }
  let(:subject) { object.emit(node, buffer) }
  let(:buffer)  { Unparser::Buffer.new      }

  let(:node) do
    location = double(
      'SourceMap',
      expression: double('SourceRange', source: 'foo')
    )

    double(
      'Node',
      type: :foo,
      location: location
    )
  end

  it 'should append source map expression to buffer' do
    expect { subject }.to change { buffer.content }.from('').to('foo')
  end
end
