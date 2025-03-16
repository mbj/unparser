require 'spec_helper'

describe Unparser::Comments, '#take_eol_comments' do
  let(:ast) do
    Unparser.parse_ast(<<~'RUBY')
      def hi # EOL 1
      =begin
      doc comment
      =end
      end # EOL 2
    RUBY
  end

  let(:object) { described_class.new(ast.comments) }

  it 'should return no comments if nothing has been consumed' do
    expect(object.take_eol_comments).to eql([])
  end

  it 'should return comments once their line has been consumed' do
    object.consume(ast.node, :name)
    expect(object.take_eol_comments).to eql([ast.comments[0]])
  end

  it 'should leave doc comments to be taken later' do
    object.consume(ast.node)
    expect(object.take_eol_comments).to eql([ast.comments[0], ast.comments[2]])
    expect(object.take_all).to eql([ast.comments[1]])
  end
end
