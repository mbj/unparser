# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name     = 'unparser'
  s.version  = '0.1.5'

  s.authors  = ['Markus Schirp']
  s.email    = 'mbj@schir-dso.com'
  s.summary  = 'Generate equivalent source for parser gem AST nodes'
  s.description = s.summary
  s.homepage = 'http://github.com/mbj/unparser'
  s.license  = 'MIT'

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.require_paths    = %w(lib)
  s.extra_rdoc_files = %w(README.md)
  s.executables      = [ 'test-unparser' ]

  s.add_dependency('parser',        '~> 2.1.0')
  s.add_dependency('concord',       '~> 0.1.4')
  s.add_dependency('adamantium',    '~> 0.1')
  s.add_dependency('equalizer',     '~> 0.0.7')
  s.add_dependency('abstract_type', '~> 0.0.7')
end
