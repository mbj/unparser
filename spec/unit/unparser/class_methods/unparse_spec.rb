require 'spec_helper'

describe Unparser, '.unparse' do
  subject { described_class.unparse(node) }

  let(:node) { mock('Node') }

  before do
    described_class::Emitter.should_receive(:visit) do |node, buffer|
      node.should be(node)
      buffer.append('foo')
    end
  end

  it { should eql('foo') }
end
