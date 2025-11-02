# frozen_string_literal: true

require 'benchmark'

RSpec.describe 'Dynamic string unparsing edge cases' do
  # Integration tests to verify roundtripping of various dynamic string patterns

  describe 'strings ending without newline' do
    it 'correctly unpars' do
      code = '"\n\n #{x}"'
      ast = Unparser.parse(code)
      unparsed = Unparser.unparse(ast)
      reparsed = Unparser.parse(unparsed)

      expect(ast).to eq(reparsed)
    end
  end

  describe 'strings with interpolation not at end' do
    it 'correctly unpars when interpolation is last' do
      code = '"foo\n#{x}"'
      ast = Unparser.parse(code)
      unparsed = Unparser.unparse(ast)
      reparsed = Unparser.parse(unparsed)

      expect(ast).to eq(reparsed)
    end

    it 'correctly unpars when str is last but no newline' do
      code = '"#{x}bar"'
      ast = Unparser.parse(code)
      unparsed = Unparser.unparse(ast)
      reparsed = Unparser.parse(unparsed)

      expect(ast).to eq(reparsed)
    end

    it 'correctly unpars when str is last with newline' do
      code = '"#{x}bar\n"'
      ast = Unparser.parse(code)
      unparsed = Unparser.unparse(ast)
      reparsed = Unparser.parse(unparsed)

      expect(ast).to eq(reparsed)
    end
  end

  describe 'complex and large dynamic strings' do
    it 'handles patterns with many interpolations' do
      # Create a complex pattern with many interpolations
      code = '"a" "#{a}" "b" "#{b}" "c" "#{c}" "d" "#{d}" "e"'
      ast = Unparser.parse(code)
      unparsed = Unparser.unparse(ast)
      reparsed = Unparser.parse(unparsed)

      expect(ast).to eq(reparsed)
    end

    it 'handles very large dynamic strings without performance issues' do
      # Create a large dynamic string with many segments
      # This ensures exhaustive search is efficient in practice
      parts = []
      20.times do |i|
        parts << '"str' + i.to_s + '"'
        parts << '"#{var' + i.to_s + '}"'
      end
      code = parts.join(' ')

      ast = Unparser.parse(code)

      # Should complete quickly despite exponential search space
      # Early termination on first valid segmentation makes this efficient
      unparsed = nil
      elapsed = Benchmark.realtime { unparsed = Unparser.unparse(ast) }

      expect(elapsed).to be < 5.0 # Should complete in under 5 seconds

      reparsed = Unparser.parse(unparsed)
      expect(ast).to eq(reparsed)
    end

    it 'handles deeply nested string concatenation' do
      # Test case that exercises the recursive segmentation search
      code = '"a" "b" "c" "#{x}" "d" "e" "f" "#{y}" "g" "h"'
      ast = Unparser.parse(code)
      unparsed = Unparser.unparse(ast)
      reparsed = Unparser.parse(unparsed)

      expect(ast).to eq(reparsed)
    end
  end
end
