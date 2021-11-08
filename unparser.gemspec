Gem::Specification.new do |gem|
  gem.name        = 'unparser'
  gem.version     = '0.6.1'

  gem.authors     = ['Markus Schirp']
  gem.email       = 'mbj@schirp-dso.com'
  gem.summary     = 'Generate equivalent source for parser gem AST nodes'

  gem.description = gem.summary
  gem.homepage    = 'http://github.com/mbj/unparser'
  gem.license     = 'MIT'

  gem.metadata = {
    'bug_tracker_uri' => 'https://github.com/mbj/unparser/issues',
    'changelog_uri'   => 'https://github.com/mbj/unparser/blob/master/Changelog.md',
    'funding_uri'     => 'https://github.com/sponsors/mbj'
  }

  gem.files            = Dir.glob('lib/**/*')
  gem.require_paths    = %w[lib]
  gem.extra_rdoc_files = %w[README.md]
  gem.executables      = %w[unparser]

  gem.required_ruby_version = '>= 2.6'

  gem.add_dependency('diff-lcs', '~> 1.3')
  gem.add_dependency('parser',   '>= 3.0.0')

  gem.add_development_dependency('mutant',            '~> 0.11.1')
  gem.add_development_dependency('mutant-rspec',      '~> 0.11.1')
  gem.add_development_dependency('rspec',             '~> 3.9')
  gem.add_development_dependency('rspec-core',        '~> 3.9')
  gem.add_development_dependency('rspec-its',         '~> 1.3.0')
  gem.add_development_dependency('rubocop',           '~> 1.7')
  gem.add_development_dependency('rubocop-packaging', '~> 0.5')
end
