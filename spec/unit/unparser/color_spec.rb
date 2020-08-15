require 'spec_helper'

describe Unparser::Color do
  shared_examples 'actual color' do |code|
    describe '#format' do

      it 'returns formatted string' do
        expect(apply).to eql("\e[#{code}mexample-string\e[0m")
      end
    end
  end

  describe '#format' do
    let(:input) { 'example-string' }

    def apply
      object.format(input)
    end

    context 'RED' do
      let(:object) { described_class::RED }

      include_examples 'actual color', 31
    end

    context 'GREEN' do
      let(:object) { described_class::GREEN }

      include_examples 'actual color', 32
    end

    context 'NONE' do
      let(:object) { described_class::NONE }

      it 'returns original input' do
        expect(apply).to be(input)
      end
    end
  end
end
