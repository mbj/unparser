# encoding: utf-8

require 'spec_helper'

describe Unparser::Comments, '#take_before' do

  let(:ast)      { ast_and_comments[0] }
  let(:comments) { ast_and_comments[1] }
  let(:object)   { described_class.new(comments) }

  context 'usual case' do

    let(:ast_and_comments) do
      Parser::CurrentRuby.parse_with_comments(<<-RUBY)
        def hi # EOL 1
          # comment
        end # EOL 2
      RUBY
    end

    it 'should return no comments if none are before the node' do
      expect(object.take_before(ast, :expression)).to eql([])
    end

    it 'should return only the comments that are before the specified part of the node' do
      expect(object.take_before(ast, :end)).to eql(comments.first(2))
      expect(object.take_all).to eql([comments[2]])
    end
  end

  context 'when node does not respond to source part' do

    let(:ast_and_comments) do
      Parser::CurrentRuby.parse_with_comments(<<-RUBY)
        expression ? :foo : :bar # EOL 1
        # EOL 2
      RUBY
    end

    it 'should return no comments if none are before the node' do
      expect(object.take_before(ast, :expression)).to eql([])
    end

    it 'should return only the comments that are before the specified part of the node' do
      expect(object.take_before(ast, :end)).to eql([])
    end
  end
end
