require 'pp'

RSpec.describe Unparser::Equalizer, '.new' do
  let(:object) { described_class }
  let(:name)   { 'User'          }
  let(:klass)  { ::Class.new     }

  context 'with no keys' do
    subject { object.new }

    before do
      allow(klass).to receive(:name).and_return(name)
      klass.send(:include, subject)
    end

    let(:instance) { klass.new }

    it { is_expected.to be_instance_of(Module) }

    describe '#eql?' do
      context 'when the objects are similar' do
        let(:other) { instance.dup }

        it { expect(instance.eql?(other)).to be(true) }
      end

      context 'when the objects are different' do
        let(:other) { double('other') }

        it { expect(instance.eql?(other)).to be(false) }
      end
    end

    describe '#==' do
      context 'when the objects are similar' do
        let(:other) { instance.dup }

        it { expect(instance == other).to be(true) }
      end

      context 'when the objects are different' do
        let(:other) { double('other') }

        it { expect(instance == other).to be(false) }
      end
    end

    describe '#hash' do
      it 'has the expected arity' do
        expect(klass.instance_method(:hash).arity).to be(0)
      end

      it { expect(instance.hash).to eql([klass].hash) }
    end

    describe '#inspect' do
      it 'returns a string representation' do
        expect(instance.inspect).to be_a(String)
        expect(instance.inspect).to match(/#</)
      end
    end

    describe '#deconstruct' do
      it 'returns empty array' do
        expect(instance.deconstruct).to eql([])
      end
    end

    describe '#deconstruct_keys' do
      it 'returns empty hash when nil' do
        expect(instance.deconstruct_keys(nil)).to eql({})
      end
    end
  end

  context 'with keys' do
    subject { object.new(*keys) }

    let(:keys)       { %i[firstname lastname].freeze  }
    let(:firstname)  { 'John'                         }
    let(:lastname)   { 'Doe'                          }
    let(:instance)   { klass.new(firstname, lastname) }

    let(:klass) do
      ::Class.new do
        attr_reader :firstname, :lastname

        def initialize(firstname, lastname)
          @firstname = firstname
          @lastname = lastname
          @extra = 'hidden'
        end
      end
    end

    before do
      allow(klass).to receive_messages(name: nil, inspect: name)
      klass.send(:include, subject)
    end

    it { is_expected.to be_instance_of(Module) }

    it 'sets a temporary name on the module' do
      expect(subject.to_s).to include('Equalizer(firstname, lastname)')
    end

    it 'makes equalizer_keys private' do
      expect(instance.private_methods).to include(:equalizer_keys)
      expect(instance.public_methods).not_to include(:equalizer_keys)
    end

    it 'includes InspectMethods by default' do
      expect(subject.ancestors).to include(Unparser::Equalizer::InspectMethods)
    end

    describe '#eql?' do
      context 'when the objects are of the same class with the same values' do
        let(:other) { instance.dup }

        it { expect(instance.eql?(other)).to be(true) }
      end

      context 'when the objects are of the same class with different values' do
        let(:other) { klass.new('Sue', 'Doe') }

        it { expect(instance.eql?(other)).to be(false) }
      end

      context 'when the objects are different classes' do
        let(:other) { double('other') }

        it { expect(instance.eql?(other)).to be(false) }
      end
    end

    describe '#==' do
      context 'when the objects of the same class with the same values' do
        let(:other) { instance.dup }

        it { expect(instance == other).to be(true) }
      end

      context 'when the objects are of the same class with different values' do
        let(:other) { klass.new('Sue', 'Doe') }

        it { expect(instance == other).to be(false) }
      end

      context 'when the objects are different type' do
        let(:other) { klass.new('Foo', 'Bar') }

        it { expect(instance == other).to be(false) }
      end

      context 'when the objects are from different type' do
        let(:other) { double('other') }

        it { expect(instance == other).to be(false) }
      end

      context 'when other is a subclass instance with the same values' do
        let(:subclass) { Class.new(klass) }
        let(:other)    { subclass.new(firstname, lastname) }

        it { expect(instance == other).to be(true) }
      end

      context 'when comparing subclass to superclass' do
        let(:subclass) { Class.new(klass) }
        let(:sub_instance) { subclass.new(firstname, lastname) }

        it { expect(sub_instance == instance).to be(false) }
      end
    end

    describe '#hash' do
      it 'returns the expected hash' do
        expect(instance.hash).to eql([klass, firstname, lastname].hash)
      end

      it 'differs when class differs' do
        other_klass = Class.new do
          include Unparser::Equalizer.new(:firstname, :lastname)
          attr_reader :firstname, :lastname

          def initialize(firstname, lastname)
            @firstname = firstname
            @lastname = lastname
          end
        end

        other = other_klass.new(firstname, lastname)
        expect(instance.hash).not_to eql(other.hash)
      end
    end

    describe '#inspect' do
      it 'returns the expected string' do
        expect(instance.inspect)
          .to match(/@firstname="John", @lastname="Doe"/)
      end

      it 'excludes non-equalizer instance variables' do
        expect(instance.inspect).not_to include('@extra')
      end

      it 'includes the object identity' do
        expect(instance.inspect).to match(/#<.*0x[0-9a-f]+/)
      end

      it 'uses bind_call on self for object identity' do
        to_s = Object.instance_method(:to_s).bind_call(instance)
        expect(instance.inspect).to start_with(to_s.sub(/>$/, ''))
      end
    end

    describe '#pretty_print' do
      it 'outputs using pp_object format with only equalizer ivars' do
        output = PP.pp(instance, StringIO.new).string
        expect(output).to include('@firstname')
        expect(output).to include('@lastname')
        expect(output).not_to include('@extra')
      end

      it 'calls pp_object on the pretty printer' do
        q = instance_double(PP)
        expect(q).to receive(:pp_object).with(instance)
        instance.pretty_print(q)
      end
    end

    describe '#pretty_print_instance_variables' do
      it 'returns ivar names for the equalizer keys' do
        expect(instance.pretty_print_instance_variables)
          .to eql(%i[@firstname @lastname])
      end
    end

    describe '#deconstruct' do
      it 'returns attribute values in order' do
        expect(instance.deconstruct).to eql(%w[John Doe])
      end

      it 'returns values via __send__' do
        expect(instance.deconstruct.length).to be(2)
      end
    end

    describe '#deconstruct_keys' do
      it 'returns all keys when nil' do
        expect(instance.deconstruct_keys(nil))
          .to eql(firstname: 'John', lastname: 'Doe')
      end

      it 'returns only requested keys' do
        expect(instance.deconstruct_keys(%i[firstname]))
          .to eql(firstname: 'John')
      end

      it 'ignores unknown keys' do
        expect(instance.deconstruct_keys(%i[unknown]))
          .to eql({})
      end
    end
  end

  context 'with inspect: false' do
    subject { object.new(:firstname, inspect: false) }

    let(:klass) do
      ::Class.new do
        attr_reader :firstname

        def initialize(firstname)
          @firstname = firstname
        end
      end
    end

    before { klass.send(:include, subject) }

    let(:instance) { klass.new('John') }

    it 'does not include InspectMethods' do
      expect(subject.ancestors).not_to include(Unparser::Equalizer::InspectMethods)
    end

    it 'does not define inspect from InspectMethods' do
      expect(subject.instance_methods).not_to include(:inspect)
    end

    it 'does not define pretty_print' do
      expect(subject.instance_methods).not_to include(:pretty_print)
    end
  end

  context 'keys are frozen' do
    it 'freezes the keys array' do
      mod = object.new(:a, :b)

      klass = Class.new do
        attr_reader :a, :b

        def initialize(a, b)
          @a = a
          @b = b
        end
      end
      klass.send(:include, mod)
      instance = klass.new(1, 2)
      expect(instance.send(:equalizer_keys)).to be_frozen
    end
  end
end
