require 'spec_helper'
require 'parser/current'

describe Unparser::Comments, '#take_before' do

  let(:ast_and_comments) do
    Parser::CurrentRuby.parse_with_comments(<<-RUBY)
      def hi # EOL 1
        # comment
      end # EOL 2
    RUBY
  end
  let(:ast)      { ast_and_comments[0] }
  let(:comments) { ast_and_comments[1] }
  let(:object)   { described_class.new(comments) }

  it 'should return no comments none are before the node' do
    expect(object.take_before(ast, :expression)).to eql([])
  end

  it 'should only the comments that are before the specified part of the node' do
    expect(object.take_before(ast, :end)).to eql(comments.first(2))
    expect(object.take_all).to eql([comments[2]])
  end
end
