require 'devtools'
Devtools.init_rake_tasks

class Rake::Task
  def overwrite(&block)
    @actions.clear
    enhance(&block)
  end
end

Rake.application.load_imports

Rake::Task['metrics:mutant'].overwrite do
  begin
    require 'mutant'
  rescue LoadError
  end
  if defined?(Mutant) and !ENV.key?('CI')
    status = Mutant::CLI.run(%W(--rspec-full ::Unparser))
    unless status.zero?
      fail "Not mutation covered :("
    end
  end
end
