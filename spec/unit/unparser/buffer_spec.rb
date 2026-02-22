require 'spec_helper'

RSpec.describe Unparser::Buffer do
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

    it_behaves_like 'a command method'
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

    it_behaves_like 'a command method'
  end

  describe '#content' do
    subject { object.content }

    let(:object) { described_class.new }

    shared_examples_for 'buffer content' do
      it 'contains expected content' do
        is_expected.to eql(expected_content)
      end

      it { is_expected.to be_frozen }

      it 'returns fresh string copies' do
        first  = object.content
        second = object.content
        expect(first).to eql(second)
        expect(first).not_to be(second)
      end
    end

    context 'with empty buffer' do
      let(:expected_content) { '' }

      it_behaves_like 'buffer content'
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

    it_behaves_like 'a command method'
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

    it 'keeps track to allow to write final' do
      object.append('foo')
      subject
      object.append('bar')
      object.final_newline
      expect(object.content).to eql("foo\nbar\n")
    end

    it 'flushes heredocs' do
      object.push_heredoc('HEREDOC')
      subject
      object.nl
      expect(object.content).to eql("\nHEREDOC\n")
    end

    it_behaves_like 'a command method'
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

    it_behaves_like 'a command method'
  end

  describe '#write_encoding' do
    let(:object) { described_class.new }

    subject { object.write_encoding(Encoding::ASCII) }

    it 'unindents two chars' do
      subject
      expect(object.content).to eql("# -*- encoding: US-ASCII -*-\n")
    end

    it_behaves_like 'a command method'
  end

  describe '#nl_flush_heredocs' do
    let(:object) { described_class.new }

    subject { object.nl_flush_heredocs }

    context 'on unbuffered heredoc' do
      context 'on fresh line' do
        it 'does nothing' do
          subject
          expect(object.content).to eql('')
        end
      end

      context 'outside fresh line' do
        it 'does nothing' do
          object.write('foo')
          subject
          expect(object.content).to eql('foo')
        end
      end
    end

    context 'on buffered heredocs' do
      context 'on fresh line' do
        it 'flushes heredoc' do
          object.push_heredoc('HEREDOC')
          subject
          expect(object.content).to eql('HEREDOC')
        end
      end

      context 'outside fresh line' do
        it 'flushes heredoc, with new line' do
          object.write('foo')
          object.push_heredoc('HEREDOC')
          subject
          expect(object.content).to eql("foo\nHEREDOC")
        end
      end
    end
  end

  describe '#final_newline' do
    let(:object) { described_class.new }

    subject { object.final_newline }

    context 'when empty' do
      it 'does nothing' do
        subject
        expect(object.content).to eql('')
      end
    end

    context 'on one line without newline' do
      it 'does not create a new line' do
        object.write('foo')
        subject
        expect(object.content).to eql('foo')
      end
    end

    context 'on one line with newline' do
      it 'does not create a new line' do
        object.write('foo')
        object.nl
        subject
        expect(object.content).to eql("foo\n")
      end
    end

    context 'more than one line, without terminating newline' do
      it 'does terminate with newline' do
        object.write('foo')
        object.nl
        object.write('bar')
        subject
        expect(object.content).to eql("foo\nbar\n")
      end
    end
  end

  describe '#ensure_nl' do
    let(:object) { described_class.new }

    subject { object.ensure_nl }

    context 'when on a new line' do
      it 'crates a new line' do
        subject
        expect(object.content).to eql('')
      end
    end

    context 'when not on a new line' do
      it 'crates a new line' do
        object.write('foo')
        subject
        expect(object.content).to eql("foo\n")
      end
    end
  end
end
