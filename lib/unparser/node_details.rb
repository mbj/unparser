# frozen_string_literal: true

module Unparser
  module NodeDetails
    include Constants, NodeHelpers

    # mutant:disable
    def self.included(descendant)
      descendant.class_eval do
        include Adamantium, Equalizer.new(:node)

        attr_reader :node

        def initialize(node)
          @node = node
        end

        extend DSL
      end
    end

    private

    def children
      node.children
    end
  end # NodeDetails
end # Unparser
