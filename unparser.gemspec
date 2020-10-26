Gem::Specification.new do |gem|
  gem.name        = 'unparser'
  gem.version     = '0.5.3'

  gem.authors     = ['Markus Schirp']
  gem.email       = 'mbj@schirp-dso.com'
  gem.summary     = 'Generate equivalent source for parser gem AST nodes'

  gem.description = gem.summary
  gem.homepage    = 'http://github.com/mbj/unparser'
  gem.license     = 'MIT'

  gem.files            = Dir.glob('lib/**/*')
  gem.require_paths    = %w[lib]
  gem.extra_rdoc_files = %w[README.md]
  gem.executables      = %w[unparser]

  gem.required_ruby_version = '>= 2.5'

  gem.add_dependency('abstract_type', '~> 0.0.7')
  gem.add_dependency('adamantium',    '~> 0.2.0')
  gem.add_dependency('anima',         '~> 0.3.1')
  gem.add_dependency('concord',       '~> 0.1.5')
  gem.add_dependency('diff-lcs',      '~> 1.3')
  gem.add_dependency('equalizer',     '~> 0.0.9')
  gem.add_dependency('mprelude',      '~> 0.1.0')
  gem.add_dependency('parser',        '>= 2.6.5')
  gem.add_dependency('procto',        '~> 0.0.2')

  gem.add_development_dependency('mutant',            '~> 0.9.14')
  gem.add_development_dependency('mutant-rspec',      '~> 0.9.14')
  gem.add_development_dependency('rspec',             '~> 3.9')
  gem.add_development_dependency('rspec-core',        '~> 3.9')
  gem.add_development_dependency('rspec-its',         '~> 1.3.0')
  gem.add_development_dependency('rubocop',           '~> 1.0.0')
  gem.add_development_dependency('rubocop-packaging', '~> 0.5.0')
end
