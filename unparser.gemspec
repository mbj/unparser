# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name     = 'unparser'
  s.version  = '0.0.1'

  s.authors  = ['Markus Schirp']
  s.email    = 'mbj@seonic.net'
  s.summary  = 'Generate equivalent source for rubies ast'
  s.homepage = 'http://github.com/mbj/unparser'

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.require_paths    = %w(lib)
  s.extra_rdoc_files = %w(README.md)

  s.add_dependency('parser',         '~> 0.9.alpha1')
  s.add_dependency('concord',        '~> 0.0.3')
  s.add_dependency('adamantium',     '~> 0.0.7')
  s.add_dependency('equalizer',      '~> 0.0.5')
  s.add_dependency('abstract_type',  '~> 0.0.5')
end
