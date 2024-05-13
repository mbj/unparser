require 'spec_helper'

describe Unparser::Comments, '#take_all' do
  let(:ast) do
    Unparser.parse_ast(<<~'RUBY')
      def hi # EOL 1
      end # EOL 2
    RUBY
  end

  let(:object) { described_class.new(ast.comments) }

  it 'should take all comments' do
    expect(object.take_all).to eql(ast.comments)
    expect(object.take_all).to eql([])
  end
end
