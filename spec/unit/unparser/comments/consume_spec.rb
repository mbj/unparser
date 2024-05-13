require 'spec_helper'

describe Unparser::Comments, '#consume' do

  let(:ast) do
    Unparser.parse_ast(<<~'RUBY')
      def hi # EOL 1
      end # EOL 2
    RUBY
  end

  let(:object) { described_class.new(ast.comments) }

  it 'should cause further EOL comments to be returned' do
    expect(object.take_eol_comments).to eql([])
    object.consume(ast.node, :name)
    expect(object.take_eol_comments).to eql([ast.comments[0]])
    object.consume(ast.node, :end)
    expect(object.take_eol_comments).to eql([ast.comments[1]])
  end
end
