Gem::Specification.new do |gem|
  gem.name        = 'unparser'
  gem.version     = '0.2.6'

  gem.authors     = ['Markus Schirp']
  gem.email       = 'mbj@schirp-dso.com'
  gem.summary     = 'Generate equivalent source for parser gem AST nodes'

  gem.description = gem.summary
  gem.homepage    = 'http://github.com/mbj/unparser'
  gem.license     = 'MIT'

  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  gem.require_paths    = %w[lib]
  gem.extra_rdoc_files = %w[README.md]
  gem.executables      = %w[unparser]

  gem.required_ruby_version = '>= 2.1'

  gem.add_dependency('abstract_type', '~> 0.0.7')
  gem.add_dependency('adamantium',    '~> 0.2.0')
  gem.add_dependency('equalizer',     '~> 0.0.9')
  gem.add_dependency('diff-lcs',      '~> 1.3')
  gem.add_dependency('concord',       '~> 0.1.5')
  gem.add_dependency('parser',        '>= 2.3.1.2', '< 2.5')
  gem.add_dependency('procto',        '~> 0.0.2')

  gem.add_development_dependency('anima',    '~> 0.3.0')
  gem.add_development_dependency('devtools', '~> 0.1.3')
  gem.add_development_dependency('morpher',  '~> 0.2.6')
end
