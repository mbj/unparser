RSpec.describe Unparser::Concord do
  let(:class_under_test) do
    Class.new do
      include Unparser::Concord.new(:foo, :bar)
    end
  end

  let(:instance_a) { class_under_test.new(foo, bar) }
  let(:instance_b) { class_under_test.new(foo, bar) }
  let(:instance_c) { class_under_test.new(foo, double('Baz')) }

  let(:foo) { double('Foo') }
  let(:bar) { double('Bar') }

  context 'initializer' do
    it 'creates a private #initialize method' do
      mod = Module.new
      expect { mod.send(:include, Unparser::Concord.new) }
        .to change { mod.private_method_defined?(:initialize) }
        .from(false).to(true)
    end

    it 'does not cause warnings' do
      begin
        original = $stderr
        $stderr = StringIO.new
        Class.new do
          include Unparser::Concord.new
        end
        expect($stderr.tap(&:rewind).read).to eql('')
      ensure
        $stderr = original
      end
    end

    it 'creates an initializer that asserts the number of arguments' do
      expect { class_under_test.new(1) }
        .to raise_error(ArgumentError, 'wrong number of arguments (1 for 2)')
    end

    it 'creates an initializer that allows 2 arguments' do
      expect { class_under_test.new(1, 2) }.to_not raise_error
    end

    it 'creates an initializer that is callable via super' do
      class_under_test.class_eval do
        attr_reader :baz
        public :foo
        public :bar

        def initialize(foo, bar)
          @baz = foo + bar
          super(foo, bar)
        end
      end

      instance = class_under_test.new(1, 2)
      expect(instance.foo).to eql(1)
      expect(instance.bar).to eql(2)
      expect(instance.baz).to eql(3)
    end

    it 'creates an initializer that is callable via zsuper' do
      class_under_test.class_eval do
        attr_reader :baz
        public :foo
        public :bar

        def initialize(foo, bar)
          @baz = foo + bar
          super
        end
      end

      instance = class_under_test.new(1, 2)
      expect(instance.foo).to eql(1)
      expect(instance.bar).to eql(2)
      expect(instance.baz).to eql(3)
    end

    it 'creates an initializer that sets the instance variables' do
      instance = class_under_test.new(1, 2)
      expect(instance.instance_variable_get(:@foo)).to be(1)
      expect(instance.instance_variable_get(:@bar)).to be(2)
    end
  end

  context 'with no objects to compose' do
    it 'assigns no ivars' do
      instance = Class.new { include Unparser::Concord.new }.new
      expect(instance.instance_variables).to be_empty
    end
  end

  context 'visibility' do
    it 'should set attribute readers to protected' do
      protected_methods = class_under_test.protected_instance_methods
      expect(protected_methods).to match_array([:foo, :bar])
    end
  end

  context 'attribute behavior' do
    subject { instance_a }

    specify { expect(subject.send(:foo)).to be(foo) }
    specify { expect(subject.send(:bar)).to be(bar) }
  end

  context 'equalization behavior' do
    specify 'composed objects are equalized on attributes' do
      expect(instance_a).to eql(instance_b)
      expect(instance_a.hash).to eql(instance_b.hash)
      expect(instance_a).to eql(instance_b)
      expect(instance_a).to_not be(instance_c)
      expect(instance_a).to_not eql(instance_c)
    end
  end

  context 'when composing too many objects' do
    specify 'it raises an error' do
      expect do
        Unparser::Concord.new(:a, :b, :c, :d)
      end.to raise_error(RuntimeError, 'Composition of more than 3 objects is not allowed')
      expect do
        Unparser::Concord.new(:a, :b, :c)
      end.to_not raise_error
    end
  end

  context Unparser::Concord::Public do
    let(:class_under_test) do
      Class.new do
        include Unparser::Concord::Public.new(:foo, :bar)
      end
    end

    it 'should create public attr readers' do
      object = class_under_test.new(:foo, :bar)
      expect(object.foo).to eql(:foo)
      expect(object.bar).to eql(:bar)
    end
  end
end
