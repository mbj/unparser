describe Unparser::Anima::Error do
  describe '#message' do
    let(:object) { described_class.new(Unparser::Anima, missing, unknown) }

    let(:missing) { %i[missing] }
    let(:unknown) { %i[unknown] }

    subject { object.message }

    it 'should return the message string' do
      should eql('Unparser::Anima attributes missing: [:missing], unknown: [:unknown]')
    end

    it_should_behave_like 'an idempotent method'
  end
end
