# encoding: utf-8

require 'spec_helper'

describe Unparser::Comments, '#consume' do

  let(:ast_and_comments) do
    Parser::CurrentRuby.parse_with_comments(<<-RUBY)
      def hi # EOL 1
      end # EOL 2
    RUBY
  end
  let(:ast)      { ast_and_comments[0] }
  let(:comments) { ast_and_comments[1] }
  let(:object)   { described_class.new(comments) }

  it 'should cause further EOL comments to be returned' do
    expect(object.take_eol_comments).to eql([])
    object.consume(ast, :name)
    expect(object.take_eol_comments).to eql([comments[0]])
    object.consume(ast, :end)
    expect(object.take_eol_comments).to eql([comments[1]])
  end
end
