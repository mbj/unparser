describe Unparser::Anima do
  let(:object) { described_class.new(:foo) }

  describe '#attributes_hash' do
    let(:value)    { double('Value')    }
    let(:instance) { double(foo: value) }

    subject { object.attributes_hash(instance) }

    it { should eql(foo: value) }
  end

  describe '#remove' do
    let(:object)  { described_class.new(:foo, :bar) }

    context 'with single attribute' do
      subject { object.remove(:bar) }

      it { should eql(described_class.new(:foo)) }
    end

    context 'with multiple attributes' do
      subject { object.remove(:foo, :bar) }

      it { should eql(described_class.new) }
    end

    context 'with inexisting attribute' do
      subject { object.remove(:baz) }

      it { should eql(object) }
    end
  end

  describe '#add' do
    context 'with single attribute' do
      subject { object.add(:bar) }

      it { should eql(described_class.new(:foo, :bar)) }
    end

    context 'with multiple attributes' do
      subject { object.add(:bar, :baz) }

      it { should eql(described_class.new(:foo, :bar, :baz)) }
    end

    context 'with duplicate attribute ' do
      subject { object.add(:foo) }

      it { should eql(object) }
    end
  end

  describe '#attributes' do
    subject { object.attributes }

    it { should eql([Unparser::Anima::Attribute.new(:foo)]) }
    it { should be_frozen                                   }
  end

  describe '#included' do
    let(:target) do
      object = self.object
      Class.new do
        include object
      end
    end

    let(:value)      { double('Value')                }
    let(:instance)   { target.new(foo: value)         }
    let(:instance_b) { target.new(foo: value)         }
    let(:instance_c) { target.new(foo: double('Bar')) }

    context 'on instance' do
      subject { instance }

      it { should eql(instance_b) }
      it { should_not eql(instance_c) }

      it 'returns expected value' do 
        expect(instance.foo).to be(value)
      end
    end

    context 'on singleton' do
      subject { target }

      it 'should define attribute hash reader' do
        expect(instance.to_h).to eql(foo: value)
      end

      specify { expect(subject.anima).to be(object) }
    end
  end

  describe '#initialize_instance' do
    let(:object) { Unparser::Anima.new(:foo, :bar) }
    let(:target) { Object.new }

    let(:foo) { double('Foo') }
    let(:bar) { double('Bar') }

    subject { object.initialize_instance(target, attribute_hash) }

    context 'when all keys are present in attribute hash' do
      let(:attribute_hash) { { foo: foo, bar: bar } }

      it 'should initialize target instance variables' do
        subject

        expect(
          target
            .instance_variables
            .map(&:to_sym)
            .to_set
        ).to eql(%i[@foo @bar].to_set)
        expect(target.instance_variable_get(:@foo)).to be(foo)
        expect(target.instance_variable_get(:@bar)).to be(bar)
      end

      it_should_behave_like 'a command method'
    end

    context 'when an extra key is present in attribute hash' do
      let(:attribute_hash) { { foo: foo, bar: bar, baz: double('Baz') } }

      it 'should raise error' do
        expect { subject }.to raise_error(
          Unparser::Anima::Error,
          Unparser::Anima::Error.new(target.class, [], [:baz]).message
        )
      end

      context 'and the extra key is falsy' do
        let(:attribute_hash) { { foo: foo, bar: bar, nil => double('Baz') } }

        it 'should raise error' do
          expect { subject }.to raise_error(
            Unparser::Anima::Error,
            Unparser::Anima::Error.new(target.class, [], [nil]).message
          )
        end
      end
    end

    context 'when a key is missing in attribute hash' do
      let(:attribute_hash) { { bar: bar } }

      it 'should raise error' do
        expect { subject }.to raise_error(
          Unparser::Anima::Error.new(target.class, [:foo], []).message
        )
      end
    end
  end

  describe 'using super in initialize' do
    subject { klass.new }

    let(:klass) do
      Class.new do
        include Unparser::Anima.new(:foo)
        def initialize(attributes = { foo: :bar })
          super
        end
      end
    end

    specify { expect(subject.foo).to eql(:bar) }
  end

  describe '#to_h on an anima infected instance' do
    subject { instance.to_h }

    let(:instance) { klass.new(params) }
    let(:params)   { Hash[foo: :bar] }
    let(:klass) do
      Class.new do
        include Unparser::Anima.new(:foo)
      end
    end

    it { should eql(params) }
  end

  describe '#with' do
    subject { object.with(attributes) }

    let(:klass) do
      Class.new do
        include Unparser::Anima.new(:foo, :bar)
      end
    end

    let(:object) { klass.new(foo: 1, bar: 2) }

    context 'with empty attributes' do
      let(:attributes) { {} }

      it { should eql(object) }
    end

    context 'with updated attribute' do
      let(:attributes) { { foo: 3 } }

      it { should eql(klass.new(foo: 3, bar: 2)) }
    end
  end
end
