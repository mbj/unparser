# frozen_string_literal: true

path_class   = Unparser::CLI.const_get(:Target).const_get(:Path)
string_class = Unparser::CLI.const_get(:Target).const_get(:String)

RSpec.describe path_class do
  describe '#initialize' do
    it 'stores the path' do
      path = Pathname.new('foo.rb')
      target = described_class.new(path)
      expect(target.path).to be(path)
    end
  end
end

RSpec.describe string_class do
  describe '#initialize' do
    it 'stores the string' do
      target = described_class.new('1 + 1')
      expect(target.string).to eql('1 + 1')
    end
  end
end
