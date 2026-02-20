RSpec.describe Unparser::Adamantium do
  describe '.included' do
    subject { descendant.instance_exec(object) { |mod| include mod } }

    let(:object)     { described_class }
    let(:superclass) { Module          }

    around do |example|
      # Restore included method after each example
      superclass.class_eval do
        alias_method :original_included, :included
        example.call
        undef_method :included
        alias_method :included, :original_included
      end
    end

    shared_examples_for 'all descendant types' do
      it 'delegates to the superclass #included method' do
        # This is the most succinct approach I could think of to test whether the
        # superclass#included method is called. All of the built-in rspec helpers
        # did not seem to work for this.
        included = 0
        superclass.class_eval { define_method(:included) { |_| included += 1 } }
        expect(included).to be(0)
        subject
        expect(included).to be(1)
      end

      it 'extends the descendant with Unparser::Adamantium::ModuleMethods' do
        subject
        expect(descendant.singleton_class.included_modules)
          .to include(Unparser::Adamantium::ModuleMethods)
      end
    end

    context 'with a class descendant' do
      let(:descendant) { Class.new }

      it_behaves_like 'all descendant types'

      it 'extends a class descendant with Unparser::Adamantium::ClassMethods' do
        subject
        expect(descendant.singleton_class.included_modules)
          .to include(Unparser::Adamantium::ClassMethods)
      end
    end

    context 'with a module descendant' do
      let(:descendant) { Module.new }

      it_behaves_like 'all descendant types'

      it 'does not extends a module descendant with Unparser::Adamantium::ClassMethods' do
        subject
        expect(descendant.singleton_class.included_modules)
          .to_not include(Unparser::Adamantium::ClassMethods)
      end
    end
  end

  describe '#new' do
    let(:argument) { 'argument' }

    subject { class_under_test.new(argument) }

    let(:class_under_test) do
      Class.new do
        include Unparser::Adamantium

        attr_reader :argument

        def initialize(argument)
          @argument = argument
        end
      end
    end

    it { is_expected.to be_frozen }

    its(:argument) { should be(argument) }
  end

  describe '#dup' do
    subject { object.dup }

    let(:object) do
      Class.new do
        include Unparser::Adamantium
      end.new
    end

    it { is_expected.to equal(object) }
  end

  describe '#freeze' do
    subject { object.freeze }

    let(:class_under_test) do
      Class.new do
        include Unparser::Adamantium

        def test
        end
      end
    end

    context 'with an unfrozen object' do
      let(:object) { class_under_test.allocate }

      it_behaves_like 'a command method'

      it 'freezes the object' do
        expect { subject }.to change(object, :frozen?)
          .from(false)
          .to(true)
      end
    end

    context 'with a frozen object' do
      let(:object) { class_under_test.new }

      it_behaves_like 'a command method'

      it 'does not change the frozen state of the object' do
        expect { subject }.to_not change(object, :frozen?)
      end
    end
  end

  describe '#memoized?' do
    subject { object.memoized?(method) }

    let(:object) do
      Class.new do
        include Unparser::Adamantium

        def some_method
        end

        def some_memoized_method
        end
        memoize :some_memoized_method
      end
    end

    context 'when method is not memoized' do
      let(:method) { :some_method }

      it { is_expected.to be(false) }
    end

    context 'when method is memoized' do
      let(:method) { :some_memoized_method }

      it { is_expected.to be(true) }
    end
  end

  describe '#unmemoized_instance_method' do
    subject { object.unmemoized_instance_method(method) }

    let(:object) do
      Class.new do
        include Unparser::Adamantium

        def some_method
        end

        def some_memoized_method
          +'foo'
        end
        memoize :some_memoized_method
      end
    end

    context 'when method is not memoized' do
      let(:method) { :some_method }

      it 'raises error' do
        expect { subject }.to raise_error(
          ArgumentError,
          '#some_method is not memoized'
        )
      end
    end

    context 'when method is memoized' do
      let(:method) { :some_memoized_method }

      it 'returns unmemoized method' do
        unmemoized = subject

        expect(unmemoized.name).to eql(method)

        instance = object.new

        bound = unmemoized.bind(instance)

        first  = bound.call
        second = bound.call

        expect(first).to eql('foo')
        expect(first).to_not be(second)
      end
    end
  end

  describe '#memoize' do
    subject { object.memoize(method) }

    let(:object) do
      Class.new do
        include Unparser::Adamantium

        def argumented(x)
        end

        def some_state
          +''
        end

        def some_other_state
        end
        memoize :some_other_state

        def public_method
        end

        protected def protected_method
        end

        private def private_method
        end
      end
    end

    shared_examples_for 'memoizes method' do
      it 'memoizes the instance method' do
        subject
        instance = object.new
        expect(instance.send(method)).to be(instance.send(method))
      end

      let(:fake) do
        Class.new do
          attr_reader :messages

          def initialize
            @messages = []
          end

          def write(message)
            @messages << message
          end
        end
      end

      it 'does not trigger warnings' do
        begin
          original = $stderr
          $stderr = fake.new
          subject
          expect($stderr.messages).to eql([])
        ensure
          $stderr = original
        end
      end

      it 'does not allow to call memoized method with blocks' do
        subject

        expect do
          object.new.send(method) { }
        end.to raise_error do |error|
          expect(error).to be_a(
            Unparser::Adamantium::MethodBuilder::BlockNotAllowedError
          )

          expect(error.message).to eql(
            "Cannot pass a block to #{object.inspect}##{method}, it is memoized"
          )
        end
      end
    end

    shared_examples_for 'wraps original method' do
      it 'creates a method with an arity of 0' do
        subject
        expect(object.new.method(method).arity).to be_zero
      end

      context 'when the initializer calls the memoized method' do
        it_behaves_like 'memoizes method'

        before do
          method = self.method
          object.send(:define_method, :initialize) { send(method) }
        end

        it 'allows the memoized method to be called within the initializer' do
          subject
          expect { object.new }.to_not raise_error
        end
      end
    end

    context 'on method with arguments' do
      let(:method) { :argumented }

      it 'should raise error' do
        expect { subject }.to raise_error(
          ArgumentError, "Cannot memoize #{object}#argumented, its arity is 1"
        )
      end
    end

    context 'memoized method that returns generated values' do
      let(:method) { :some_state }

      it_behaves_like 'a command method'
      it_behaves_like 'memoizes method'
      it_behaves_like 'wraps original method'

      it 'creates a method that returns a frozen value' do
        subject
        expect(object.new.send(method)).to be_frozen
      end

      it 'creates a method that returns expected value' do
        subject

        expect(object.new.some_state).to eql('')
      end

      it 'creates a method that returns same value for each call' do
        subject

        instance = object.new

        expect(instance.some_state).to be(instance.some_state)
      end

      it 'does not get confused with sibling memoized methods' do
        subject

        instance = object.new
        instance.some_other_state

        expect(instance.some_other_state).to_not be(instance.some_state)

        expect(instance.some_state).to be(instance.some_state)
      end

      it 'does not allow repated memoization' do
        subject

        expect { subject.memoize(method) }.to raise_error(
          ArgumentError,
          "##{method} is already memoized"
        )
      end
    end

    context 'public method' do
      let(:method) { :public_method }

      it_behaves_like 'a command method'
      it_behaves_like 'memoizes method'
      it_behaves_like 'wraps original method'

      it 'is still a public method' do
        is_expected.to be_public_method_defined(method)
      end

      it 'creates a method that returns a frozen value' do
        subject
        expect(object.new.send(method)).to be_frozen
      end
    end

    context 'protected method' do
      let(:method) { :protected_method }

      it_behaves_like 'a command method'
      it_behaves_like 'memoizes method'

      it 'is still a protected method' do
        is_expected.to be_protected_method_defined(method)
      end

      it 'creates a method that returns a frozen value' do
        subject
        expect(object.new.send(method)).to be_frozen
      end
    end

    context 'private method' do
      let(:method) { :private_method }

      it_behaves_like 'a command method'
      it_behaves_like 'memoizes method'

      it 'is still a private method' do
        is_expected.to be_private_method_defined(method)
      end

      it 'creates a method that returns a frozen value' do
        subject
        expect(object.new.send(method)).to be_frozen
      end
    end
  end
end
