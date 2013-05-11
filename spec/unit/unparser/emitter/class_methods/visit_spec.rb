require 'spec_helper'

describe Unparser::Emitter, '.visit' do
  subject { described_class.visit(node, buffer) }

  let(:node)   { mock('Node', :type => type) }
  let(:buffer) { Unparser::Buffer.new        }

  class Dummy < Unparser::Emitter
    handle :dummy

    def dispatch
      emit('foo')
    end
  end

  context 'when handler for type is registred' do
    let(:type) { :dummy }

    it { should eql(Dummy.new(node, buffer)) }
  end

  context 'when handler for type is NOT registred' do
    let(:type) { :unknown }

    it 'should raise error' do
      expect { subject }.to raise_error(ArgumentError, 'No emitter for node: :unknown')
    end
  end
end
