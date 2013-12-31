# encoding: utf-8

require 'spec_helper'

describe Unparser::Comments, '#take_all' do

  let(:ast_and_comments) do
    Parser::CurrentRuby.parse_with_comments(<<-RUBY)
      def hi # EOL 1
      end # EOL 2
    RUBY
  end
  let(:ast)      { ast_and_comments[0] }
  let(:comments) { ast_and_comments[1] }
  let(:object)   { described_class.new(comments) }

  it 'should take all comments' do
    expect(object.take_all).to eql(comments)
    expect(object.take_all).to eql([])
  end
end
