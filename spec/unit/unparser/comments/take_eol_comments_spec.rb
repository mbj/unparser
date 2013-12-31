# encoding: utf-8

require 'spec_helper'

describe Unparser::Comments, '#take_eol_comments' do

  let(:ast_and_comments) do
    Parser::CurrentRuby.parse_with_comments(<<-RUBY)
def hi # EOL 1
=begin
doc comment
=end
end # EOL 2
    RUBY
  end
  let(:ast)              { ast_and_comments[0] }
  let(:comments)         { ast_and_comments[1] }
  let(:object)           { described_class.new(comments) }

  it 'should return no comments if nothing has been consumed' do
    expect(object.take_eol_comments).to eql([])
  end

  it 'should return comments once their line has been consumed' do
    object.consume(ast, :name)
    expect(object.take_eol_comments).to eql([comments[0]])
  end

  it 'should leave doc comments to be taken later' do
    object.consume(ast)
    expect(object.take_eol_comments).to eql([comments[0], comments[2]])
    expect(object.take_all).to eql([comments[1]])
  end
end
