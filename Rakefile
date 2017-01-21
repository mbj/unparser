require 'devtools'
Devtools.init_rake_tasks

Rake.application.load_imports
task('metrics:mutant').clear

namespace :metrics do
  task mutant: :coverage do
    args = %w[
      bundle exec mutant
      --include lib
      --require unparser
      --use rspec
      --zombie
      --since HEAD~1
    ]
    args.concat(%w[--jobs 4]) if ENV.key?('CIRCLECI')

    system(*args.concat(%w[-- Unparser*])) or fail "Mutant task failed"
  end
end
