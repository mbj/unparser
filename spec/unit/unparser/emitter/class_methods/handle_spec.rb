require 'spec_helper'

RSpec.describe Unparser::Emitter, '.handle', mutant_expression: 'Unparser*' do
  subject { class_under_test.class_eval { handle :foo } }

  let(:class_under_test) do
    Class.new(described_class)
  end

  before do
    stub_const('Unparser::Emitter::REGISTRY', {})
  end

  it 'should register emitter' do
    expect { subject }.to change { Unparser::Emitter::REGISTRY }.from({}).to(foo: class_under_test)
  end
end
