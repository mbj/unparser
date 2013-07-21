require 'devtools'
Devtools.init_rake_tasks

Rake.application.load_imports
task('metrics:mutant').clear

namespace :metrics do
  task :mutant => :coverage do
    $stderr.puts 'Mutant is disabled till flexible rspec strategy is implemented'
  end
end
