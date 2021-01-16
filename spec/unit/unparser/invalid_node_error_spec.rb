# frozen_string_literal: true

RSpec.describe Unparser::InvalidNodeError do
  let(:node)    { s(:some_node) }
  let(:message) { 'message'.dup }

  subject { described_class.new(message, node) }

  its(:node)    { should be(node)    }
  its(:message) { should be(message) }
  its(:frozen?) { should be(true)    }
end
