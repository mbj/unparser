# frozen_string_literal: true

RSpec.describe Unparser::Diff do
  let(:object) { described_class }

  describe '.build' do

    subject { object.build(old_string, new_string) }

    let(:old_string) { "foo\nbar" }
    let(:new_string) { "bar\nbaz" }

    it { should eql(described_class.new(%w[foo bar], %w[bar baz])) }

  end

  describe '#colorized_diff' do
    let(:object) { described_class.new(old, new) }

    subject { object.colorized_diff }

    context 'when there is a diff at begin of hunk' do
      let(:old) { %w[foo bar] }
      let(:new) { %w[baz bar] }

      let(:expectation) do
        [
          "@@ -1,2 +1,2 @@\n",
          Unparser::Color::RED.format("-foo\n"),
          Unparser::Color::GREEN.format("+baz\n"),
          " bar\n"
        ].join
      end

      it { should eql(expectation) }

      it_should_behave_like 'an idempotent method'
    end

    context 'when there is no diff' do
      let(:old) { '' }
      let(:new) { '' }

      it { should be(nil) }

      it_should_behave_like 'an idempotent method'
    end
  end

  describe '#diff' do
    let(:object) { described_class.new(old, new) }

    subject { object.diff }

    context 'when there is a diff at begin and end' do
      let(:old) { %w[foo bar foo] }
      let(:new) { %w[baz bar baz] }

      let(:expectation) do
        <<~STR
          @@ -1,3 +1,3 @@
          -foo
          +baz
           bar
          -foo
          +baz
        STR
      end

      it { should eql(expectation) }

      it_should_behave_like 'an idempotent method'
    end

    context 'when there is a diff at begin of hunk' do
      let(:old) { %w[foo bar] }
      let(:new) { %w[baz bar] }

      let(:expectation) do
        <<~STR
          @@ -1,2 +1,2 @@
          -foo
          +baz
           bar
        STR
      end

      it { should eql(expectation) }

      it_should_behave_like 'an idempotent method'
    end

    context 'when there is a diff NOT at begin of hunk' do
      let(:old) { %w[foo bar]     }
      let(:new) { %w[foo baz bar] }

      let(:expectation) do
        <<~STR
          @@ -1,2 +1,3 @@
           foo
          +baz
           bar
        STR
      end

      it { should eql(expectation) }

      it_should_behave_like 'an idempotent method'
    end

    context 'when the diff has a long context at begin' do
      let(:old) { %w[foo bar baz boz a b c]       }
      let(:new) { %w[foo bar baz boz a b c other] }

      let(:expectation) do
        <<~STR
          @@ -1,7 +1,8 @@
           foo
           bar
           baz
           boz
           a
           b
           c
          +other
        STR
      end

      it { should eql(expectation) }

      it_should_behave_like 'an idempotent method'
    end

    context 'when the diff has a long context at end, deleting' do
      let(:old) { %w[other foo bar baz boz a b c] }
      let(:new) { %w[foo bar baz boz a b c]       }

      let(:expectation) do
        <<~STR
          @@ -1,8 +1,7 @@
          -other
           foo
           bar
           baz
           boz
           a
           b
           c
        STR
      end

      it { should eql(expectation) }

      it_should_behave_like 'an idempotent method'
    end

    context 'when the diff has a long context at end, inserting' do
      let(:old) { %w[foo bar baz boz a b c]       }
      let(:new) { %w[other foo bar baz boz a b c] }

      let(:expectation) do
        <<~STR
          @@ -1,7 +1,8 @@
          +other
           foo
           bar
           baz
           boz
           a
           b
           c
        STR
      end

      it { should eql(expectation) }

      it_should_behave_like 'an idempotent method'
    end

    context 'when there is no diff' do
      let(:old) { '' }
      let(:new) { '' }

      it { should be(nil) }

      it_should_behave_like 'an idempotent method'
    end
  end
end
