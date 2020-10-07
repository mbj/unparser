require 'spec_helper'

describe Unparser::Buffer do
  describe '#append' do
    subject { object.append(string) }

    let(:object) { described_class.new }
    let(:string) { 'foo' }

    specify do
      expect { subject }.to change { object.content }.from('').to('foo')
    end

    it 'should prefix with indentation if line is empty' do
      object.append('foo')
      object.nl
      object.indent
      object.append('bar')
      object.append('baz')
      expect(object.content).to eql("foo\n  barbaz")
    end

    it_should_behave_like 'a command method'
  end

  describe '#append_without_prefix' do
    subject { object.append_without_prefix(string) }

    let(:object) { described_class.new }
    let(:string) { 'foo' }

    specify do
      expect { subject }.to change { object.content }.from('').to('foo')
    end

    it 'should not prefix with indentation' do
      object.append_without_prefix('foo')
      object.nl
      object.indent
      object.append_without_prefix('bar')
      object.append_without_prefix('baz')
      expect(object.content).to eql("foo\nbarbaz")
    end

    it_should_behave_like 'a command method'
  end

  describe '#capture_content' do
    let(:object) { described_class.new }

    it 'should capture only the content appended within the block' do
      object.append('foo')
      object.nl
      object.indent
      captured = object.capture_content do
        object.append('bar')
        object.nl
      end
      expect(captured).to eql("  bar\n")
    end
  end

  describe '#content' do
    subject { object.content }

    let(:object) { described_class.new }

    shared_examples_for 'buffer content' do
      it 'contains expected content' do
        should eql(expected_content)
      end

      it { should be_frozen }

      it 'returns fresh string copies' do
        first  = object.content
        second = object.content
        expect(first).to eql(second)
        expect(first).not_to be(second)
      end
    end

    context 'with empty buffer' do
      let(:expected_content) { '' }

      it_should_behave_like 'buffer content'
    end

    context 'with filled buffer' do
      before do
        object.append('foo')
      end

      let(:expected_content) { 'foo' }

      it_behaves_like 'buffer content'
    end
  end

  describe '#fresh_line?' do
    let(:object) { described_class.new }

    it 'should return true while buffer is empty' do
      expect(object.fresh_line?).to eql(true)
    end

    it 'should return false after content has been appended' do
      object.append('foo')
      expect(object.fresh_line?).to eql(false)
    end

    it 'should return true after a nl has been appended' do
      object.append('foo')
      object.nl
      expect(object.fresh_line?).to eql(true)
    end
  end

  describe '#indent' do
    let(:object) { described_class.new }

    subject { object.indent }

    it 'should indent with two spaces' do
      object.append('foo')
      object.nl
      object.indent
      object.append('bar')
      object.nl
      object.indent
      object.append('baz')
      expect(object.content).to eql("foo\n  bar\n    baz")
    end

    it_should_behave_like 'a command method'
  end

  describe '#nl' do
    let(:object) { described_class.new }

    subject { object.nl }

    it 'writes a newline' do
      object.append('foo')
      subject
      object.append('bar')
      expect(object.content).to eql("foo\nbar")
    end

    it_should_behave_like 'a command method'
  end

  describe '#unindent' do
    let(:object) { described_class.new }

    subject { object.unindent }

    it 'unindents two chars' do
      object.append('foo')
      object.nl
      object.indent
      object.append('bar')
      object.nl
      object.unindent
      object.append('baz')
      expect(object.content).to eql("foo\n  bar\nbaz")
    end

    it_should_behave_like 'a command method'
  end
end
