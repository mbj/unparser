require 'spec_helper'

describe Unparser::Buffer, '#append' do
  subject { object.append(string) }

  let(:object) { described_class.new }
  let(:string) { 'foo' }

  specify do 
    expect { subject }.to change { object.content }.from('').to('foo')
  end

  it_should_behave_like 'a command method'
end
