# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'mutant',       github: 'mbj/mutant', glob: 'ruby/*.gemspec', branch: 'main'
gem 'mutant-rspec', github: 'mbj/mutant', glob: 'ruby/*.gemspec', branch: 'main'

group :development do
  # Duel requires Ruby 3.4 or later. Platforms, rather than a check of
  # RUBY_VERSION, keep Gemfile.lock the same on Ruby 3.3, where CI
  # installs the bundle in deployment mode. Add each new Ruby here.
  gem 'duel', '>= 0.1.1', platforms: %w[mri_34 mri_40 mri_41]
  gem 'stackprof', platforms: :mri
end
