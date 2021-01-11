describe Unparser::Anima::Attribute do
  let(:object) { described_class.new(:foo) }

  describe '#get' do
    subject { object.get(target) }

    let(:target_class) do
      Class.new do
        attr_reader :foo

        def initialize(foo)
          @foo = foo
        end
      end
    end

    let(:target) { target_class.new(value) }
    let(:value) { double('Value') }

    it 'should return value' do
      should be(value)
    end
  end

  describe '#load' do
    subject { object.load(target, attribute_hash) }

    let(:target)         { Object.new      }
    let(:value)          { double('Value') }
    let(:attribute_hash) { { foo: value }  }

    it 'should set value as instance variable' do
      subject
      expect(target.instance_variable_get(:@foo)).to be(value)
    end

    it_should_behave_like 'a command method'
  end

  describe '#instance_variable_name' do
    subject { object.instance_variable_name }

    it { should be(:@foo) }

    it_should_behave_like 'an idempotent method'
  end

  describe '#set' do
    subject { object.set(target, value) }

    let(:target) { Object.new }

    let(:value) { double('Value') }

    it_should_behave_like 'a command method'

    it 'should set value as instance variable' do
      subject
      expect(target.instance_variable_get(:@foo)).to be(value)
    end
  end
end
