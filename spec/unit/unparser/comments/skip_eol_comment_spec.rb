require 'spec_helper'
require 'parser/current'

describe Unparser::Comments, '#skip_eol_comment' do

  let(:ast_and_comments) do
    Parser::CurrentRuby.parse_with_comments(<<-RUBY)
      def hi # comment
      end # comment
    RUBY
  end
  let(:ast)              { ast_and_comments[0] }
  let(:comments)         { ast_and_comments[1] }
  let(:object)           { described_class.new(comments) }

  it 'should skip the specified comment only for one subsequent take' do
    object.consume(ast, :name)
    object.skip_eol_comment('# comment')
    expect(object.take_eol_comments).to eql([])
    object.consume(ast, :end)
    expect(object.take_eol_comments).to eql([comments[1]])
  end

  it 'should not skip comments with different text' do
    object.skip_eol_comment('# not the comment')
    object.consume(ast, :end)
    expect(object.take_eol_comments).to eql(comments)
  end
end
