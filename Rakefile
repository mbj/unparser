require 'devtools'
Devtools.init_rake_tasks

Rake.application.load_imports
task('metrics:mutant').clear

namespace :metrics do
  task mutant: :coverage do
    system(*%w[
      bundle exec mutant
        --include lib
        --require unparser
        --use rspec
        --zombie
        --since HEAD~1
        --
        Unparser*
    ]) or fail "Mutant task failed"
  end
end
