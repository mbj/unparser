# frozen_string_literal: true

# Unparser.unparse, which mutant calls for every mutation it makes. The
# ASTs are built in `once` from the fixed sources in duel/fixtures, so
# only the unparsing is timed.

require_relative 'duel_helper'

duel 'unparse: a single method call' do
  once { @node = Unparser.parse('foo.bar(baz, 1, key: :value)') }
  Unparser.unparse(@node)
end

duel 'unparse: a typical method' do
  once { @node = def_node('lib/cli.rb', :process_target) }
  Unparser.unparse(@node)
end

duel 'unparse: each method of a class' do
  once { @nodes = def_nodes(fixture_node('lib/cli.rb')) }
  unparse_each(@nodes)
end

duel 'unparse: a large file' do
  once { @node = fixture_node('lib/generation.rb') }
  Unparser.unparse(@node)
end

duel 'unparse: a large file with comments' do
  once { @ast = Unparser.parse_ast(fixture('lib/generation.rb')) }
  Unparser.unparse_ast(@ast)
end

duel 'unparse: strings and interpolation' do
  once { @node = fixture_node('corpus/dstr.rb') }
  Unparser.unparse(@node)
end

duel 'unparse: heredocs' do
  once { @node = fixture_node('corpus/heredoc.rb') }
  Unparser.unparse(@node)
end

duel 'unparse: blocks' do
  once { @node = fixture_node('corpus/block.rb') }
  Unparser.unparse(@node)
end

duel 'unparse: pattern matching' do
  once { @node = fixture_node('corpus/pattern.rb') }
  Unparser.unparse(@node)
end

duel 'unparse: method calls and arguments' do
  once { @node = fixture_node('corpus/send_arguments.rb') }
  Unparser.unparse(@node)
end

duel 'unparse: calls on compound receivers' do
  once { @node = fixture_node('corpus/send_receivers.rb') }
  Unparser.unparse(@node)
end

duel 'unparse: operators' do
  once { @nodes = corpus_nodes('binary', 'unary') }
  unparse_each(@nodes)
end

duel 'unparse: method definitions' do
  once { @node = fixture_node('corpus/def.rb') }
  Unparser.unparse(@node)
end

duel 'unparse: literals' do
  once { @node = fixture_node('corpus/literal.rb') }
  Unparser.unparse(@node)
end

duel 'unparse: conditionals and loops' do
  once { @nodes = corpus_nodes('if', 'case', 'while') }
  unparse_each(@nodes)
end

duel 'unparse: assignments' do
  once { @nodes = corpus_nodes('assignment', 'opasgn') }
  unparse_each(@nodes)
end

duel 'unparse: rescue and ensure' do
  once { @nodes = corpus_nodes('kwbegin', 'rescue') }
  unparse_each(@nodes)
end

duel 'unparse: regexps and ranges' do
  once { @nodes = corpus_nodes('regexp', 'range') }
  unparse_each(@nodes)
end
