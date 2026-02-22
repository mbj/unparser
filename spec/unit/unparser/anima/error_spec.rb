RSpec.describe Unparser::Anima::Error do
  describe '#message' do
    let(:object) { described_class.new(Unparser::Anima, missing, unknown) }

    let(:missing) { %i[missing] }
    let(:unknown) { %i[unknown] }

    subject { object.message }

    it 'should return the message string' do
      is_expected.to eql('Unparser::Anima attributes missing: [:missing], unknown: [:unknown]')
    end

    it_behaves_like 'an idempotent method'
  end
end
