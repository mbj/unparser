require 'spec_helper'

RSpec.describe Unparser::Color do
  describe '#initialize' do
    it 'stores the code' do
      color = described_class.new(31)
      expect(color.format('text')).to eql("\e[31mtext\e[0m")
    end
  end

  describe '#format' do
    let(:input) { 'example-string' }

    def apply
      object.format(input)
    end

    context 'RED' do
      let(:object) { described_class::RED }

      it 'returns formatted string' do
        expect(apply).to eql("\e[31mexample-string\e[0m")
      end
    end

    context 'GREEN' do
      let(:object) { described_class::GREEN }

      it 'returns formatted string' do
        expect(apply).to eql("\e[32mexample-string\e[0m")
      end
    end

    context 'NONE' do
      let(:object) { described_class::NONE }

      it 'returns original input' do
        expect(apply).to be(input)
      end
    end
  end
end
