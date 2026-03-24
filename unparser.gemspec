Gem::Specification.new do |gem|
  gem.name        = 'unparser'
  gem.version     = '0.9.0'

  gem.authors     = ['Markus Schirp']
  gem.email       = 'mbj@schirp-dso.com'
  gem.summary     = 'Generate equivalent source for parser gem AST nodes'

  gem.description = gem.summary
  gem.homepage    = 'https://github.com/mbj/unparser'
  gem.license     = 'MIT'

  gem.metadata = {
    'homepage_uri'          => gem.homepage,
    'bug_tracker_uri'       => "#{gem.homepage}/issues",
    'changelog_uri'         => "#{gem.homepage}/blob/main/Changelog.md",
    'funding_uri'           => 'https://github.com/sponsors/mbj',
    'source_code_uri'       => gem.homepage,
    'rubygems_mfa_required' => 'true'
  }

  gem.files            = Dir.glob('lib/**/*')
  gem.require_paths    = %w[lib]
  gem.extra_rdoc_files = %w[README.md]
  gem.executables      = %w[unparser]

  gem.required_ruby_version = '>= 3.3'

  gem.add_dependency('diff-lcs', '>= 1.6', '< 3')
  gem.add_dependency('parser',   '>= 3.3.0')
  gem.add_dependency('prism',    '>= 1.5.1')

  gem.add_development_dependency('benchmark',         '~> 0.5.0')
  gem.add_development_dependency('mutant',            '>= 0.14.2')
  gem.add_development_dependency('mutant-rspec',      '>= 0.14.2')
  gem.add_development_dependency('rspec',             '>= 3.13', '< 5')
  gem.add_development_dependency('rspec-core',        '>= 3.13', '< 5')
  gem.add_development_dependency('rspec-its',         '~> 2.0')
  gem.add_development_dependency('rspectre',          '~> 0.2.0')
  gem.add_development_dependency('rubocop',           '~> 1.7')
  gem.add_development_dependency('rubocop-packaging', '~> 0.5')
end
