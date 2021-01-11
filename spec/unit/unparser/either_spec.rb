# frozen_string_literal: true

RSpec.shared_examples 'no block evaluation' do
  context 'with block' do
    let(:block) { -> { fail } }

    it 'does not evaluate block' do
      apply
    end
  end
end

RSpec.shared_examples 'requires block' do
  context 'without block' do
    let(:block) { nil }

    specify do
      expect { apply }.to raise_error(LocalJumpError)
    end
  end
end

RSpec.shared_examples 'returns self' do
  it 'returns self' do
    expect(apply).to be(subject)
  end
end

RSpec.shared_examples '#bind block evaluation' do
  it 'evaluates block and returns its wrapped result' do
    expect { expect(apply).to eql(block_result) }
      .to change(yields, :to_a)
      .from([])
      .to([value])
  end
end

RSpec.shared_examples 'Functor#fmap block evaluation' do
  it 'evaluates block and returns its wrapped result' do
    expect { expect(apply).to eql(described_class.new(block_result)) }
      .to change(yields, :to_a)
      .from([])
      .to([value])
  end
end

RSpec.describe Unparser::Either do
  describe '.wrap_error' do
    let(:block)           { -> { fail error } }
    let(:error)           { exception.new     }
    let(:exception)       { TestError         }
    let(:other_exception) { OtherTestError    }

    class TestError < RuntimeError; end

    class OtherTestError < RuntimeError; end

    shared_examples 'block returns' do
      let(:value) { instance_double(Object, 'value') }
      let(:block) { -> { value }                     }

      it 'returns right wrapping block value' do
        expect(apply).to eql(described_class::Right.new(value))
      end
    end

    shared_examples 'covered exception' do
      it 'returns left wrapping exception' do
        expect(apply).to eql(described_class::Left.new(error))
      end
    end

    shared_examples 'uncovered exception' do
      let(:unexpected_exception) { StandardError }

      let(:block) { -> { fail unexpected_exception } }

      it 'returns raises error' do
        expect { apply }.to raise_error(unexpected_exception)
      end
    end

    context 'on single exception argument' do
      def apply
        described_class.wrap_error(exception, &block)
      end

      context 'when block returns' do
        include_examples 'block returns'
      end

      context 'when block raises' do
        context 'with covered exception' do
          include_examples 'covered exception'
        end

        context 'with uncovered exception' do
          include_examples 'uncovered exception'
        end
      end
    end

    context 'on multiple exception arguments' do
      def apply
        described_class.wrap_error(exception, other_exception, &block)
      end

      context 'when block returns' do
        include_examples 'block returns'
      end

      context 'when block raises' do
        context 'with covered exception' do
          include_examples 'covered exception'
        end

        context 'with uncovered exception' do
          include_examples 'uncovered exception'
        end

        context 'with other covered exception' do
          let(:block)       { -> { fail other_error } }
          let(:other_error) { other_exception.new     }

          it 'returns left wrapping exception' do
            expect(apply).to eql(described_class::Left.new(other_error))
          end
        end
      end
    end
  end
end

RSpec.describe Unparser::Either::Left do
  subject { described_class.new(value) }

  let(:block_result) { instance_double(Object, 'block result') }
  let(:value)        { instance_double(Object, 'value')        }
  let(:yields)       { []                                      }

  let(:block) do
    lambda do |value|
      yields << value
      block_result
    end
  end

  class TestError < RuntimeError; end

  describe '#fmap' do
    def apply
      subject.fmap(&block)
    end

    include_examples 'no block evaluation'
    include_examples 'requires block'
    include_examples 'returns self'
  end

  describe '#bind' do
    def apply
      subject.bind(&block)
    end

    include_examples 'no block evaluation'
    include_examples 'requires block'
    include_examples 'returns self'
  end

  describe '#from_left' do
    def apply
      subject.from_left(&block)
    end

    it 'returns left value' do
      expect(apply).to be(value)
    end

    include_examples 'no block evaluation'
  end

  describe '#from_right' do
    def apply
      subject.from_right(&block)
    end

    context 'without block' do
      let(:block) { nil }

      it 'raises RuntimeError error' do
        expect { apply }.to raise_error(
          RuntimeError,
          "Expected right value, got #{subject.inspect}"
        )
      end
    end

    context 'with block' do
      let(:yields)       { []                                      }
      let(:block_return) { instance_double(Object, 'block-return') }

      let(:block) do
        lambda do |value|
          yields << value
          block_return
        end
      end

      it 'calls block with left value' do
        expect { apply }.to change(yields, :to_a).from([]).to([value])
      end

      it 'returns block value' do
        expect(apply).to be(block_return)
      end
    end
  end

  describe '#lmap' do
    def apply
      subject.lmap(&block)
    end

    include_examples 'requires block'
    include_examples 'Functor#fmap block evaluation'
  end

  describe '#either' do
    def apply
      subject.either(block, -> { fail })
    end

    include_examples '#bind block evaluation'
  end

  describe '#left?' do
    def apply
      subject.left?
    end

    it 'returns true' do
      expect(apply).to be(true)
    end
  end

  describe '#right?' do
    def apply
      subject.right?
    end

    it 'returns false' do
      expect(apply).to be(false)
    end
  end
end

RSpec.describe Unparser::Either::Right do
  subject { described_class.new(value) }

  let(:block_result) { instance_double(Object, 'block result') }
  let(:value)        { instance_double(Object, 'value')        }
  let(:yields)       { []                                      }

  let(:block) do
    lambda do |value|
      yields << value
      block_result
    end
  end

  describe '#fmap' do
    def apply
      subject.fmap(&block)
    end

    include_examples 'requires block'
    include_examples 'Functor#fmap block evaluation'
  end

  describe '#bind' do
    def apply
      subject.bind(&block)
    end

    include_examples 'requires block'
    include_examples '#bind block evaluation'
  end

  describe '#from_left' do
    def apply
      subject.from_left(&block)
    end

    context 'without block' do
      let(:block) { nil }

      it 'raises RuntimeError error' do
        expect { apply }.to raise_error(
          RuntimeError,
          "Expected left value, got #{subject.inspect}"
        )
      end
    end

    context 'with block' do
      let(:yields)       { []                                      }
      let(:block_return) { instance_double(Object, 'block-return') }

      let(:block) do
        lambda do |value|
          yields << value
          block_return
        end
      end

      it 'calls block with right value' do
        expect { apply }.to change(yields, :to_a).from([]).to([value])
      end

      it 'returns block value' do
        expect(apply).to be(block_return)
      end
    end
  end

  describe '#from_right' do
    def apply
      subject.from_right(&block)
    end

    it 'returns right value' do
      expect(apply).to be(value)
    end

    include_examples 'no block evaluation'
  end

  describe '#lmap' do
    def apply
      subject.lmap(&block)
    end

    include_examples 'requires block'
    include_examples 'no block evaluation'

    it 'returns self' do
      expect(apply).to be(subject)
    end
  end

  describe '#either' do
    def apply
      subject.either(-> { fail }, block)
    end

    include_examples '#bind block evaluation'
  end

  describe '#left?' do
    def apply
      subject.left?
    end

    it 'returns false' do
      expect(apply).to be(false)
    end
  end

  describe '#right?' do
    def apply
      subject.right?
    end

    it 'returns true' do
      expect(apply).to be(true)
    end
  end
end
