# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name     = 'unparser'
  gem.version  = '0.1.16'

  gem.authors  = ['Markus Schirp']
  gem.email    = 'mbj@schir-dso.com'
  gem.summary  = 'Generate equivalent source for parser gem AST nodes'
  gem.description = gem.summary
  gem.homepage = 'http://github.com/mbj/unparser'
  gem.license  = 'MIT'

  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  gem.require_paths    = %w(lib)
  gem.extra_rdoc_files = %w(README.md)
  gem.executables      = [ 'unparser' ]

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_dependency('parser',        '~> 2.2.0.pre.7')
  gem.add_dependency('procto',        '~> 0.0.2')
  gem.add_dependency('concord',       '~> 0.1.5')
  gem.add_dependency('adamantium',    '~> 0.2.0')
  gem.add_dependency('equalizer',     '~> 0.0.9')
  gem.add_dependency('abstract_type', '~> 0.0.7')
end
