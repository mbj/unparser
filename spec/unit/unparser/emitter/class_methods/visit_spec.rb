require 'spec_helper'

describe Unparser::Emitter, '.visit' do
  subject { object.visit(node, buffer) }
  let(:object) { described_class }

  let(:node)   { mock('Node', :type => type, :source_map => nil) }
  let(:buffer) { Unparser::Buffer.new        }

  before do
    stub_const('Unparser::Emitter::REGISTRY', { :dummy => Dummy })
  end

  class Dummy < Unparser::Emitter
    def self.emit(node, buffer)
      buffer.append('foo')
    end
  end

  context 'when handler for type is registred' do
    let(:type) { :dummy }
    it_should_behave_like 'a command method'

    it 'should call emitter' do
      subject
      buffer.content.should eql('foo')
    end
  end

  context 'when handler for type is NOT registred' do
    let(:type) { :unknown }

    it 'should raise error' do
      expect { subject }.to raise_error(ArgumentError, 'No emitter for node: :unknown')
    end
  end
end
