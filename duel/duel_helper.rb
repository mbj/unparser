# frozen_string_literal: true

# Shared helpers for the benchmarks. The fixtures are fixed copies of
# files from lib/ and test/corpus/, so the benchmarks measure the same
# input whatever later changes to those files.

FIXTURES = File.expand_path('fixtures', __dir__)

def fixture(path)
  File.read(File.join(FIXTURES, path))
end

# The AST of a fixture, without its comments
def fixture_node(path)
  Unparser.parse(fixture(path))
end

# The ASTs of several corpus fixtures, each parsed on its own
def corpus_nodes(*names)
  names.map { |name| fixture_node("corpus/#{name}.rb") }
end

# Every method definition in a node, in source order
def def_nodes(node)
  return [] unless node.is_a?(Parser::AST::Node)

  own = node.type.equal?(:def) ? [node] : []
  own + node.children.flat_map { |child| def_nodes(child) }
end

# The method definition of the given name in a fixture
def def_node(path, name)
  def_nodes(fixture_node(path)).detect { |node| node.children.first.equal?(name) }
end

def unparse_each(nodes)
  nodes.each { |node| Unparser.unparse(node) }
end
