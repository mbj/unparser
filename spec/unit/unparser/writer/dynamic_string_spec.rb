# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Unparser::Writer::DynamicString do
  context 'when dynamic string does not end with newline' do
    let(:original_code) { "\"a\\nb\nc\#{1}d\"" }

    it 'maintains semantic equivalence when evaluated' do
      original_ast = Unparser.parse(original_code)
      generated_code = Unparser.unparse(original_ast)

      # Must be parseable
      expect { Unparser.parse(generated_code) }.not_to raise_error

      # Both should evaluate to the same result
      original_result = eval(original_code)
      generated_result = eval(generated_code)
      expect(generated_result).to eq(original_result)

      expect(generated_code).to eq("<<-HEREDOC.chomp\na\nb\nc\#{1}d\nHEREDOC\n")
    end

    context 'when dynamic string does end with newline' do
      let(:original_code) { "\"a\\nb\nc\#{1}d\n\"" }

      it 'maintains semantic equivalence when evaluated' do
        original_ast = Unparser.parse(original_code)
        generated_code = Unparser.unparse(original_ast)

        # Must be parseable
        expect { Unparser.parse(generated_code) }.not_to raise_error

        # Both should evaluate to the same result
        original_result = eval(original_code)
        generated_result = eval(generated_code)
        expect(generated_result).to eq(original_result)

        expect(generated_code).to eq("<<-HEREDOC\na\nb\nc\#{1}d\nHEREDOC\n")
      end
    end
  end
end
