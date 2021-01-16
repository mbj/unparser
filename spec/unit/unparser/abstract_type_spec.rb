RSpec.shared_examples 'AbstractType.create_new_method' do
  context 'called on a subclass' do
    let(:object) { Class.new(abstract_type) }

    it { should be_instance_of(object) }
  end

  context 'called on the class' do
    let(:object) { abstract_type }

    specify do
      expect { subject }.to raise_error(
        NotImplementedError,
        "#{object} is an abstract type"
      )
    end
  end
end

RSpec.describe Unparser::AbstractType::AbstractMethodDeclarations, '#abstract_method' do
  subject { object.abstract_method(:some_method) }

  let(:object)   { Class.new { include Unparser::AbstractType } }
  let(:subclass) { Class.new(object)                            }

  before do
    Subclass = subclass
  end

  after do
    Object.class_eval { remove_const(:Subclass) }
  end

  it { should equal(object) }

  it 'creates an abstract method' do
    expect { subject }.to change { subclass.method_defined?(:some_method) }
      .from(false)
      .to(true)
  end

  it 'creates an abstract method with the expected arity' do
    subject
    expect(object.instance_method(:some_method).arity).to be(-1)
  end

  it 'creates a method that raises an exception' do
    subject
    expect { subclass.new.some_method }.to raise_error(
      NotImplementedError,
      'Subclass#some_method is not implemented'
    )
  end
end

RSpec.describe(
  Unparser::AbstractType::AbstractMethodDeclarations,
  '#abstract_singleton_method'
) do
  subject { object.abstract_singleton_method(:some_method) }

  let(:object)   { Class.new { include Unparser::AbstractType } }
  let(:subclass) { Class.new(object)                            }

  before do
    Subclass = subclass
  end

  after do
    Object.class_eval { remove_const(:Subclass) }
  end

  it { should equal(object) }

  it 'creates an abstract method' do
    expect { subject }.to change { subclass.respond_to?(:some_method) }
      .from(false)
      .to(true)
  end

  it 'creates an abstract method with the expected arity' do
    subject
    expect(object.method(:some_method).arity).to be(-1)
  end

  it 'creates a method that raises an exception' do
    subject
    expect { subclass.some_method }.to raise_error(
      NotImplementedError,
      'Subclass.some_method is not implemented'
    )
  end
end

RSpec.describe Unparser::AbstractType, '.included' do
  subject { object }

  let(:object) { described_class }
  let(:klass)  { Class.new       }

  it 'extends the klass' do
    expect(klass.singleton_class)
      .to_not include(described_class::AbstractMethodDeclarations)
    klass.send(:include, subject)
    expect(klass.singleton_class)
      .to include(described_class::AbstractMethodDeclarations)
  end

  it 'overrides the new singleton method' do
    expect(klass.method(:new).owner).to eq(Class)
    klass.send(:include, subject)
    expect(klass.method(:new).owner).to eq(klass.singleton_class)
  end

  it 'delegates to the ancestor' do
    included_ancestor = false
    subject.extend Module.new {
      define_method(:included) { |_| included_ancestor = true }
    }
    expect { klass.send(:include, subject) }
      .to change { included_ancestor }.from(false).to(true)
  end
end

RSpec.describe Unparser::AbstractType, '.create_new_method' do
  context 'with arguments' do
    subject { object.new(:foo) }

    let(:abstract_type) do
      Class.new do
        include Unparser::AbstractType

        def initialize(foo)
          @foo = foo
        end
      end
    end

    it_behaves_like 'AbstractType.create_new_method'
  end

  context 'with a block' do
    subject { object.new(:foo) { nil } }

    let(:abstract_type) do
      Class.new do
        include Unparser::AbstractType

        def initialize(foo)
          @foo = foo
          yield
        end
      end
    end

    it_behaves_like 'AbstractType.create_new_method'
  end

  context 'without arguments' do
    subject { object.new }

    let(:abstract_type) { Class.new { include Unparser::AbstractType } }

    it_behaves_like 'AbstractType.create_new_method'
  end

  context 'on an class that doesn\'t have Object as its superclass' do
    subject { object.new }

    let(:abstract_type) { Class.new(RuntimeError) { include Unparser::AbstractType } }

    it_behaves_like 'AbstractType.create_new_method'
  end
end
