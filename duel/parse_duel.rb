# frozen_string_literal: true

# Unparser's parsing helpers, which build the AST that unparser
# understands (with the parser gem or Prism's translation, depending on
# the Ruby), and unparse_validate, which checks a round trip.

require_relative 'duel_helper'

duel 'parse: a short method' do
  once do
    @source = <<~RUBY
      def call(input)
        return if input.empty?

        input.map { |item| item.fetch(:name) }.join(', ')
      end
    RUBY
  end
  Unparser.parse(@source)
end

duel 'parse: a typical file' do
  once { @source = fixture('lib/cli.rb') }
  Unparser.parse(@source)
end

duel 'parse: a large file with comments' do
  once { @source = fixture('lib/generation.rb') }
  Unparser.parse_ast(@source)
end

duel 'validate: a typical method' do
  once { @node = def_node('lib/cli.rb', :process_target) }
  Unparser.unparse_validate(@node)
end

duel 'validate: a large file' do
  once { @node = fixture_node('lib/generation.rb') }
  Unparser.unparse_validate(@node)
end
