require 'spec_helper'

RSpec.describe Unparser::Comments, '#take_before' do
  let(:object) { described_class.new(ast.comments) }

  context 'usual case' do
    let(:ast) do
      Unparser.parse_ast(<<~'RUBY')
        def hi # EOL 1
          # comment
        end # EOL 2
      RUBY
    end

    it 'should return no comments if none are before the node' do
      expect(object.take_before(ast.node, :expression)).to eql([])
    end

    it 'should return only the comments that are before the specified part of the node' do
      expect(object.take_before(ast.node, :end)).to eql(ast.comments.first(2))
      expect(object.take_all).to eql([ast.comments[2]])
    end
  end

  context 'when node does not respond to source part' do

    let(:ast) do
      Unparser.parse_ast(<<~'RUBY')
        expression ? :foo : :bar # EOL 1
        # EOL 2
      RUBY
    end

    it 'should return no comments if none are before the node' do
      expect(object.take_before(ast.node, :expression)).to eql([])
    end

    it 'should return only the comments that are before the specified part of the node' do
      expect(object.take_before(ast.node, :end)).to eql([])
    end
  end
end
